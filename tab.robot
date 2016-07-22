*** Settings ***
Library   Selenium2Screenshots
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   tab_service.py


*** Variables ***
${sign_in_form}                                                 jquery=div.login_form_button
${login_sign_in}                                                jquery=input#user_email
${password_sign_in}                                             jquery=input#user_password
${sign_in_button}                                               jquery=input[value="Увійти"]









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
  Sleep   200
