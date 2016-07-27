*** Settings ***
Library   Selenium2Screenshots
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   tab_service.py


*** Variables ***
${CREATE_TENDER_PAGE}                                           http://tr1tr.tab.com.ua/tenders/new

${sign_in_form}                                                 jquery=div.login_form_button
${login_sign_in}                                                jquery=input#user_email
${password_sign_in}                                             jquery=input#user_password
${sign_in_button}                                               jquery=input[value="Увійти"]
${unit_code_selector}                                           jquery=div.select_tender_items_attributes__0__unit_code_







${locator.title}                                                css=.qa_title
${locator.status}                                               xpath=//td[contains(@class, 'zk-status')]
${locator.description}                                          css=.qa_descr
${locator.minimalStep.amount}                                   css=.qa_min_budget
${locator.value.amount}                                         css=.qa_budget_pdv
${locator.tenderId}                                             xpath=//dd[contains(@class, 'tender-tuid')]
${locator.procuringEntity.name}                                 css=.qa_procuring_entity
${locator.enquiryPeriod.startDate}                              css=.qa_date_period_clarifications
${locator.enquiryPeriod.endDate}                                css=.qa_date_period_clarifications
${locator.tenderPeriod.startDate}                               css=.qa_date_submission_of_proposals
${locator.tenderPeriod.endDate}                                 css=.qa_date_submission_of_proposals
${locator.items[0].quantity}                                    xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].description}                                 css=.qa_item_name
${locator.items[0].deliveryLocation.latitude}                   css=.qa_place_delivery
${locator.items[0].deliveryLocation.longitude}                  css=.qa_place_delivery
${locator.items[0].unit.code}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].unit.name}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].deliveryAddress.postalCode}                  css=.qa_address_delivery
${locator.items[0].deliveryAddress.countryName}                 css=.qa_address_delivery
${locator.items[0].deliveryAddress.region}                      css=.qa_address_delivery
${locator.items[0].deliveryAddress.locality}                    css=.qa_address_delivery
${locator.items[0].deliveryAddress.streetAddress}               css=.qa_address_delivery
${locator.items[0].classification.scheme}                       css=.qa_cpv_name
${locator.items[0].classification.id}                           css=.qa_cpv_classifier
${locator.items[0].classification.description}                  css=.qa_cpv_classifier
${locator.questions[0].title}                                   css=.qa_message_title
${locator.questions[0].description}                             css=.qa_message_description
${locator.questions[0].date}                                    css=.qa_question_date
${locator.questions[0].answer}                                  css=.zk-question__answer-body


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Tab_Viewer'   Login   ${ARGUMENTS[0]}

Login
  [Arguments]  @{ARGUMENTS}
  Click Element   ${sign_in_form}
  Sleep   1
  Clear Element Text   ${login_sign_in}
  Input text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button    ${sign_in_button}
  Sleep   1

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}
  ${tender_data}=   adapt_minimalStep   ${tender_data}
  [Return]  ${tender_data}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

  # Tender info variables
  ${title}=                               Get From Dictionary         ${ARGUMENTS[1].data}                    title
  ${description}=                         Get From Dictionary         ${ARGUMENTS[1].data}                    description
  ${budget}=                              Get From Dictionary         ${ARGUMENTS[1].data.value}              amount
  ${currency}=                            Get From Dictionary         ${ARGUMENTS[1].data.value}              currency
  ${valueAddedTaxIncluded}=               Get From Dictionary         ${ARGUMENTS[1].data.value}              valueAddedTaxIncluded
  ${minimalStepPercentage}                adapt_minimalStep           ${ARGUMENTS[1].data}
  ${minimalStepAmount}                    Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}        amount
  ${enquiryPeriod}=                       Get From Dictionary         ${ARGUMENTS[1].data}                    enquiryPeriod
  ${endPeriodAdjustments}=                get_tender_dates            ${ARGUMENTS[1]}                         endPeriod
  ${endReceiveOffers}=                    get_tender_dates            ${ARGUMENTS[1]}                         endDate

  # Product/Service info variables
  ${items}=                               Get From Dictionary         ${ARGUMENTS[1].data}                    items
  ${item0}=                               Get From List               ${items}                                0
  ${descrLot}=                            Get From Dictionary         ${item0}                                description
  ${unitCode}=                            Get From Dictionary         ${item0.unit}                           code
  ${quantity}=                            Get From Dictionary         ${item0}                                quantity
  ${deliveryFromDate}=                    Get From Dictionary         ${item0.deliveryDate}                   endDate
  ${deliveryFromDate}=                    parseDates                  ${deliveryFromDate}
  ${deliveryToDate}=                      Get From Dictionary         ${item0.deliveryDate}                   endDate
  ${deliveryToDate}=                      parseDates                  ${deliveryToDate}
  ${postalCode}=                          Get From Dictionary         ${item0.deliveryAddress}                postalCode
  ${locality}=                            Get From Dictionary         ${item0.deliveryAddress}                locality
  ${streetAddress}=                       Get From Dictionary         ${item0.deliveryAddress}                streetAddress
  ${region}=                              Get From Dictionary         ${item0.deliveryAddress}                region





  ${cav_id}=                              Get From Dictionary         ${item0.classification}                 id
  ${latitude}=                            Get From Dictionary         ${item0.deliveryLocation}               latitude
  ${longitude}=                           Get From Dictionary         ${item0.deliveryLocation}               longitude






  # Start executing
  Go to                                   ${CREATE_TENDER_PAGE}

  # Tender info
  Wait Until Page Contains Element        jquery=input#tender_title                                           20
  Input text                              jquery=input#tender_title                                           ${title}
  Input text                              jquery=input#tender_description                                     ${description}
  ${budget}=                              Convert To String                                                   ${budget}
  Input text                              jquery=input#tender_value_attributes_amount                         ${budget}
  ${minimalStepAmount}=                   Convert To String                                                   ${minimalStepAmount}
  Input text                              jquery=input#tender_minimal_step_attributes_amount                  ${minimalStepAmount}
  ${minimalStepPercentage}=               Convert To String                                                   ${minimalStepPercentage}
  Input text                              jquery=input#tender_minimal_step_attributes_percent                 ${minimalStepPercentage}
  Sleep                                   1
  Execute Javascript                      (function(){window.$('input#tender_value_attributes_included_tax').click();})()
  Input text                              jquery=input#tender_enquiry_period_attributes_end_date              ${endPeriodAdjustments}
  Input text                              jquery=input#tender_tender_period_attributes_end_date               ${endReceiveOffers}
  Sleep                                   1

  # Product/Service info
  Input text                              jquery=input#tender_items_attributes_0_description                  ${descrLot}
  Input text                              jquery=input#tender_items_attributes_0_quantity                     ${quantity}
  Wait Until Page Contains Element        ${unit_code_selector}                                               20
  Click Element                           ${unit_code_selector}
  Sleep                                   1
  ${unitCodeSelector}=                    chooseUnit                                                          ${unitCode}
  Click Element                           jquery=${unitCodeSelector}
  Input text                              jquery=input#tender_items_attributes_0_delivery_date_attributes_start_date              ${deliveryFromDate}
  Input text                              jquery=input#tender_items_attributes_0_delivery_date_attributes_end_date                ${deliveryToDate}
  Input text                              jquery=input#tender_items_attributes_0_region                       ${region}
  Input text                              jquery=input#tender_items_attributes_0_locality                     ${locality}
  Input text                              jquery=input#tender_items_attributes_0_street_address               ${streetAddress}
  Input text                              jquery=input#tender_items_attributes_0_postal_code                  ${postalCode}
  Sleep                                   1

  # Submit tender
  Execute Javascript                      (function(){window.$('span:contains("Опублікувати")').click();})()

  Sleep                                   20

  [Return]  ${tender_data}