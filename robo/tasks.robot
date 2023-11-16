*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Resource            ../robocorp/task.robot


*** Tasks ***
Open the robot order website
    Open website

Order Robots
    Fill the form using the data from the CSV file


*** Keywords ***
Open website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Fill and Submit the form for one person
    [Arguments]    ${robot_order}
    Click Button    css:.alert-buttons > button:nth-child(1)
    Wait Until Element Is Visible    //*[@id="head"]
    Select From List By Value    //*[@id="head"]    ${robot_order}[Head]
    Input Text    address    ${robot_order}[Address]
    Select Radio Button    body    ${robot_order}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${robot_order}[Legs]
    Wait Until Keyword Succeeds    10x    2s    Preview the robot
    Wait Until Keyword Succeeds    10x    2s    Submit The Order
    Screenshot    //*[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}${robot_order}[Order number].png
    Wait Until Element Is Visible    //*[@id="receipt"]
    ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    content=${order_receipt_html}    output_path=${OUTPUT_DIR}${/}${robot_order}[Order number].pdf
    Click Button    //*[@id="order-another"]

Fill the form using the data from the CSV file
    Open Workbook    orders.xlsx
    ${robot_order}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${robot_order}    IN    @{robot_order}
        Fill and submit the form for one person    ${robot_order}
    END

Preview the robot
    Click Button    //*[@id="preview"]
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]

Submit The Order
    Click Button    //*[@id="order"]
    Page Should Contain Element    //*[@id="receipt"]
