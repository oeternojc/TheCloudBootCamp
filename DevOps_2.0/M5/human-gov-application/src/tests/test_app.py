import pytest
from app import home_page

def test_home_page():
    assert home_page('staging') == 'Human Resources Management System - State of staging'