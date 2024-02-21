import asyncio
import random
import pandas as pd
import streamlit as st
from st_aggrid import AgGrid, GridOptionsBuilder
from st_aggrid.shared import GridUpdateMode
from pandas import DataFrame

from api.auth import AuthEndpoint
from api.statements import StatementsEndpoint
from lib.config import Config
from lib.flink import Changelog


def aggrid_interactive_table(df: pd.DataFrame):
    """Creates an st-aggrid interactive table based on a dataframe.

    Args:
        df (pd.DataFrame]): Source dataframe

    Returns:
        dict: The selected row
    """
    options = GridOptionsBuilder.from_dataframe(
        df, enableRowGroup=True, enableValue=True, enablePivot=True,
    )

    options.configure_side_bar()

    options.configure_selection("single")
    selection = AgGrid(
        df,
        enable_enterprise_modules=True,
        gridOptions=options.build(),
        update_mode=GridUpdateMode.MODEL_CHANGED,
        allow_unsafe_jscode=True,
        height=500, width=200
    )

    return selection



async def query(conf, sql, continuous_query):
    auth = AuthEndpoint(conf)
    statements = StatementsEndpoint(auth, conf)

    stmt = await statements.create(sql)
    print(f'running statement {sql}')
    ready = await statements.wait_for_status(stmt, 'running', 'completed')
    print(f'ready = {ready}')
    schema = ready['status']['result_schema']
    name = ready['name']
    # this is an async generator, not a blocking function
    results = statements.results(name, continuous_query)
    return results, schema


def random_array_of_tuples(n):
    return [(random.randint(1, 10), random.randint(1, 1000)) for _ in range(n)]


async def populate_table(widget, sql, continuous_query):
    conf = Config('./config.yml')
    print(conf)
    results, schema = await query(conf, sql, continuous_query)
    print(f'results = {results}')
    changelog = Changelog(schema, results)
    await changelog.consume(1)
    table = changelog.collapse()
    while True:
        new_data = await changelog.consume(1)
        table.update(new_data)
        # wait until we get the update-after to render, otherwise graphs
        # and tables content "jump" around.
        if new_data[0][0] != "-U":
            df = DataFrame(table, None, table.columns)
            df.sort_values(by=df.columns[0], inplace=True)
            widget.dataframe(df, hide_index=True,
                             column_config={"state": "state"})
        await asyncio.sleep(0.01)


async def main():
    # st.title("Weather on Confluent Cloud from Flink")
    # col1, col2 = st.columns(2)
    #
    # with col1:
    #     st.header("States")

    st.set_page_config(
        layout="wide", page_icon="🖱️", page_title="Interactive Weather app"
    )
    st.title("🖱️ Interactive Weather App")
    st.write(
        """This app shows how you can use the streamlit-aggrid
        Streamlit component in an interactive way so as to display additional content 
        based on user click."""
    )

    st.write("Go ahead, click on a row in the table below!")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.header("States")

        selection = aggrid_interactive_table(df=pd.read_json('./data/states.json'))
        if selection:
            st.write("You selected:")
            st.json(selection["selected_rows"])

    with col2:
        st.header("Active Alerts")
        active_alerts = st.empty()

    # states_table_query = """
    #     select distinct(state) as state from NoaaZonesInbound limit 60;
    #     """
    # await asyncio.gather(
    #     populate_table(states_table, states_table_query, continuous_query=True)
    # )




# if __name__ == "__main__":
asyncio.run(main())