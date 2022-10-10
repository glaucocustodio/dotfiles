#!/usr/bin/env python3.7

import iterm2
# This script was created with the "basic" environment which does not support adding dependencies
# with pip.

async def main(connection):
    # Your code goes here. Here's a bit of example code that adds a tab to the current window:
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window
    if window is not None:
        await window.async_create_tab()
        # Get the active session in this tab
        session = app.current_terminal_window.current_tab.current_session
        # Send text to the session as though the user had typed it
        await session.async_send_text('cdv\n')
        await session.async_send_text('make run\n')

        # Open another tab
        await window.async_create_tab()
        session = app.current_terminal_window.current_tab.current_session
        await session.async_send_text('cdv\n')
        await session.async_send_text('make jobs\n')

        # Open another tab
        await window.async_create_tab()
        session = app.current_terminal_window.current_tab.current_session
        await session.async_send_text('cdv\n')
        await session.async_send_text('make run_client\n')

        # Open another tab
        await window.async_create_tab()
        session = app.current_terminal_window.current_tab.current_session
        await session.async_send_text('cdv\n')
        await session.async_send_text('make console\n')
    else:
        # You can view this message in the script console.
        print("No current window")

iterm2.run_until_complete(main)
