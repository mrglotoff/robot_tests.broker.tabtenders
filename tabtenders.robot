*** Settings ***
Library   Selenium2Screenshots
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   tab_service.py


*** Variables ***
${CREATE_TENDER_PAGE}                                           http://tr1tr.tab.com.ua/tenders/new
${signInForm}                                                   jquery=div.login_form_button
${loginField}                                                   jquery=input#user_email
${passwordForm}                                                 jquery=input#user_password
${sign_in_button}                                               jquery=input[value="Увійти"]
${unit_code_selector}                                           jquery=div.select_tender_items_attributes__0__unit_code_



*** Variables ***
${locator.title}                                                jquery=div.tender_title
${locator.status}                                               jquery=div.tender_status
${locator.description}                                          jquery=div.tender_description
${locator.minimalStep.amount}                                   jquery=div.tender_minimal_step > span.amount
${locator.value.amount}                                         jquery=div.tender_value > span.amount
${locator.value.tax}                                            jquery=div.tender_value > span.light
${locator.procuringEntity.name}                                 jquery=div.tender-info-item:contains("Найменування замовника")>div.info-item-content
${locator.tenderId}                                             jquery=span.tender_prozorro_id
${locator.enquiryPeriod.endDate}                                jquery=span.enquiry_end_date
${locator.tenderPeriod.endDate}                                 jquery=span.tender_end_date
${locator.items[0].quantity}                                    jquery=span.quantity_amount
${locator.items[0].description}                                 jquery=h4.nom-collapse-title
${locator.items[0].deliveryDate.endDate}                        jquery=span.delivery_end_date
${locator.items[0].deliveryAddress.postalCode}                  jquery=span.address_zip
${locator.items[0].deliveryAddress.countryName}                 jquery=span.address_country
${locator.items[0].deliveryAddress.region}                      jquery=span.address_region
${locator.items[0].deliveryAddress.locality}                    jquery=span.address_locality
${locator.items[0].deliveryAddress.streetAddress}               jquery=span.address_street
${locator.items[0].classification.id}                           jquery=span.item_classification_code
${locator.items[0].classification.description}                  jquery=span.item_classification_name
${locator.items[0].additionalClassifications[0].id}             jquery=span.item_addclassification_code
${locator.items[0].additionalClassifications[0].description}    jquery=span.item_addclassification_name

${locator.questions[0].title}                                   jquery=div#discussion-collapse div.discussions-text div.title
${locator.questions[0].description}                             jquery=div#discussion-collapse div.discussions-text div.text
${locator.questions[0].date}                                    jquery=div#discussion-collapse div.discussions-text div.datetime
${locator.questions[0].answer}                                  jquery=div#discussion-collapse div.discussions-answer div.text


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]                             @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open browser          ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If        '${ARGUMENTS[0]}' != 'tabtenders_Viewer'             login               ${ARGUMENTS[0]}



Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${tender_data}=   adaptProcuringEntity   ${tender_data}
  [Return]  ${tender_data}



Login
  [Arguments]                             @{ARGUMENTS}
  Log to console                          \n[ INFO ] : Log in
  Click Element                           ${signInForm}
  Sleep   1

  Clear Element Text                      ${loginField}
  Input text                              ${loginField}               ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text                              ${passwordForm}             ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button                            ${sign_in_button}



Створити тендер
  [Arguments]                             @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

  #Contact info
  ${contactName}=                         Get From Dictionary         ${ARGUMENTS[1].data.procuringEntity.contactPoint}                   name
  ${contactPhone}=                        Get From Dictionary         ${ARGUMENTS[1].data.procuringEntity.contactPoint}                   telephone


  # Tender info variables
  ${title}=                               Get From Dictionary         ${ARGUMENTS[1].data}                    title
  ${description}=                         Get From Dictionary         ${ARGUMENTS[1].data}                    description
  ${budget}=                              Get From Dictionary         ${ARGUMENTS[1].data.value}              amount
  ${currency}=                            Get From Dictionary         ${ARGUMENTS[1].data.value}              currency
  ${valueAddedTaxIncluded}=               Get From Dictionary         ${ARGUMENTS[1].data.value}              valueAddedTaxIncluded
  ${minimalStepAmount}                    Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}        amount
  ${enquiryPeriod}=                       Get From Dictionary         ${ARGUMENTS[1].data}                    enquiryPeriod
  ${endPeriodAdjustments}=                getTenderDates              ${ARGUMENTS[1]}                         endPeriod
  ${endReceiveOffers}=                    getTenderDates              ${ARGUMENTS[1]}                         endDate

  # Product/Service info variables
  ${items}=                               Get From Dictionary         ${ARGUMENTS[1].data}                    items
  ${item0}=                               Get From List               ${items}                                0
  ${descrLot}=                            Get From Dictionary         ${item0}                                description
  ${unitCode}=                            Get From Dictionary         ${item0.unit}                           code
  ${quantity}=                            Get From Dictionary         ${item0}                                quantity
  ${deliveryFromDate}=                    getTenderDates              ${ARGUMENTS[1]}                         deliveryStartDate
  ${deliveryToDate}=                      Get From Dictionary         ${item0.deliveryDate}                   endDate
  ${deliveryToDate}=                      parseDates                  ${deliveryToDate}
  ${postalCode}=                          Get From Dictionary         ${item0.deliveryAddress}                postalCode
  ${locality}=                            Get From Dictionary         ${item0.deliveryAddress}                locality
  ${streetAddress}=                       Get From Dictionary         ${item0.deliveryAddress}                streetAddress
  ${region}=                              Get From Dictionary         ${item0.deliveryAddress}                region
  ${cpvIdMain}=                           Get From Dictionary         ${item0.classification}                 id
  ${cpvIdAdditional}=                     Get From Dictionary         ${item0.additionalClassifications[0]}   id


  # Start executing
  Go to                                   ${CREATE_TENDER_PAGE}
  Log to console                          \n[ INFO ] : Tender type quiz

  # Tender type
  Wait Until Page Contains Element        jquery=div.modal_title                                              20
  Click Element                           jquery=li.procedure_1
  Sleep                                   1
  Click Element                           jquery=li.organization_type_1
  Sleep                                   1
  Click Element                           jquery=li.tender_items_type_1
  Sleep                                   1
  ${tenderAmountType}                     tenderAmountType                                                    ${budget}
  Click Element                           jquery=${tenderAmountType}
  Sleep                                   1
  ${lotAmountType}                        lotAmountType                                                       ${items}
  Click Element                           jquery=${lotAmountType}
  Sleep                                   1

  tabtenders.Run test session
  Log to console                          [ INFO ] : Start to fill tender info

  # Tender info
  Wait Until Page Contains Element        jquery=input#tender_title                                           20
  Input text                              jquery=input#tender_title                                           ${title}
  Input text                              jquery=textarea#tender_description                                  ${description}
  ${budget}=                              Convert To String                                                   ${budget}
  Input text                              jquery=input#tender_value_attributes_amount                         ${budget}
  ${minimalStepAmount}=                   Convert To String                                                   ${minimalStepAmount}
  Input text                              jquery=input#tender_minimal_step_attributes_amount                  ${minimalStepAmount}
  Execute Javascript                      (function(){window.$('input#tender_value_attributes_included_tax').click();})()

  Log to console                          [ INFO ] : Fill dates
  Input text                              jquery=input#tender_enquiry_period_attributes_end_date              ${endPeriodAdjustments}
  Log to console                          [ INFO ] : Завершення періоду уточнень - initial_tender_data.data.tenderPeriod.startDate - ${endPeriodAdjustments}
  Sleep                                   1
  Click Element                           jquery=input#tender_tender_period_attributes_end_date
  Sleep                                   1
  Input text                              jquery=input#tender_tender_period_attributes_end_date               ${endReceiveOffers}
  Log to console                          [ INFO ] : Завершення прийому пропозицій - initial_tender_data.data.tenderPeriod.endDate - ${endReceiveOffers}
  Execute Javascript                      (function(){window.$('input#tender_guarantee_attributes_guarantee_type_1').click();})()

  Log to console                          [ INFO ] : Start to fill Product/Service info

  # Product/Service info
  Input text                              jquery=input#tender_items_attributes_0_description                  ${descrLot}
  Input text                              jquery=input#tender_items_attributes_0_quantity                     ${quantity}
  Wait Until Page Contains Element        ${unit_code_selector}                                               20
  Click Element                           ${unit_code_selector}
  Sleep                                   1
  ${unitCodeSelector}=                    chooseUnit                                                          ${unitCode}
  Click Element                           jquery=${unitCodeSelector}
  Sleep                                   1
  Log to console                          [ INFO ] : Item info filled

  Click Element                           jquery=span.btn_editing[data-type="cpv"]
  Wait Until Page Contains Element        jquery=input#search_dkpp2015                                        20

  Input text                              jquery=input#search_dkpp2015                                        ${cpvIdMain}
  Execute Javascript                      (function(){window.$('input[value="${cpvIdMain}"]').click();})()
  Click Element                           jquery=span:contains("Зберегти")
  Sleep                                   1
  Click Element                           jquery=span.btn_editing[data-type="dkpp"]
  Wait Until Page Contains Element        jquery=input#search_dkpp2010                                        20
  Input text                              jquery=input#search_dkpp2010                                        ${cpvIdAdditional}
  Execute Javascript                      (function(){window.$('input[value="${cpvIdAdditional}"]').click();})()
  Sleep                                   1
  Execute Javascript                      (function(){window.$('span:contains("Зберегти")').click();})()
  Sleep                                   1
  Log to console                          [ INFO ] : CPV filled\n[ INFO ] : Start to fill Delivery info

  Input text                              jquery=input#tender_items_attributes_0_delivery_date_attributes_start_date              ${deliveryFromDate}
  Input text                              jquery=input#tender_items_attributes_0_delivery_date_attributes_end_date                ${deliveryToDate}
  Input text                              jquery=input#tender_items_attributes_0_region                       ${region}
  Input text                              jquery=input#tender_items_attributes_0_locality                     ${locality}
  Input text                              jquery=input#tender_items_attributes_0_street_address               ${streetAddress}
  Input text                              jquery=input#tender_items_attributes_0_postal_code                  ${postalCode}
  Sleep                                   1
  Log to console                          [ INFO ] : Delivery info filled\n

  # Submit tender
  Sleep   1
  Click Element                           jquery=input.send_to_prozorro
  Log to console                          [ INFO ] : Send to Prozorro

  # Get tender ID
  Wait Until Page Contains Element        jquery=span.tender_ua_id                                            180
  ${tenderID}=                            Get Text                                                            jquery=span.tender_ua_id
  Log to console                          [ INFO ] : Tender ID: ${tenderID}
  Sleep                                   1

  [Return]  ${tenderID}



Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${user}
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${tenderID}
  Log to console                          \n[ INFO ] : Завантаження документа
  tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                                ${ARGUMENTS[2]}
  Sleep                                   1
  Click Element                           jquery=a.tender_edit
  tabtenders.Run test session
  Sleep                                   2
  Click Element                           jquery=a.documents_add
  Sleep                                   2
  Choose File                             jquery=input[type="file"]                       ${ARGUMENTS[1]}
  Sleep                                   3
  Click Element                           jquery=input.send_to_prozorro
  Log to console                          [ INFO ] : Зміни опубліковано
  Sleep                                   1



Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_id
  Log to console                          \n[ INFO ] : Пошук тендера по ідентифікатору
  Go to                                   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Sleep                                   1
  Input Text                              jquery=input[name="key"]                                            ${ARGUMENTS[1]}
  Sleep                                   1
  Click Button                            jquery=input[name="search_submit"]
  Sleep                                   1

  # Page Should Contain Element             jquery=div.tender-title-info                      Tender page not loaded                          WARN
  Sleep                                   1
  Log to console                          [ INFO ] : Tender ID: ${ARGUMENTS[1]}
  Log to console                          [ INFO ] : Сторінку тендера завантажено



Оновити сторінку з тендером
  [Arguments]    @{ARGUMENTS}
  [Documentation]    ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  Log to console                          \n[ INFO ] : Оновлення сторінки з тендером
  Selenium2Library.Switch Browser          ${ARGUMENTS[0]}
  Reload Page



Run test session
  [Arguments]                             @{ARGUMENTS}
  Log to console                          \n[ INFO ] : Відкрити у тестовому режимі
  Execute Javascript                      (function(){ window.$('body')[0].classList.add("_TEST_");})()
  Sleep                                   1



Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_id
  ...      ${ARGUMENTS[2]} ==  question
  ${title}=                           Get From Dictionary               ${ARGUMENTS[2].data}            title
  ${description}=                     Get From Dictionary               ${ARGUMENTS[2].data}            description
  Log to console                      \n[ INFO ] : Задати питання
  Log to console                      "@{ARGUMENTS}"

  tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                ${ARGUMENTS[1]}

  Click Element                       jquery=a[aria-controls="discussion-collapse"]
  Sleep   1
  Click Element                       jquery=a.discussion_add
  Wait Until Page Contains Element    jquery=input#tender_question_title                    20
  Input text                          jquery=input#tender_question_title                    ${title}
  Input text                          jquery=textarea#tender_question_description           ${description}
  Click Element                       jquery=input[type="commit"]
  Sleep    10
  Reload page
  Click Element                       jquery=a[aria-controls="discussion-collapse"]
  # Focus                               jquery=a.discussion_add

  Capture page screenshot
  Log to console                      [ INFO ] : Питання задано



Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data
  Log to console                      \n[ INFO ] : Відповісти на питання
  Log to console           "@{ARGUMENTS}"

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}

  tabtenders.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                       jquery=a[aria-controls="discussion-collapse"]
  Sleep                               1
  Wait Until Page Contains Element    jquery=a.answer_add                         20
  Click Element                       jquery=a.answer_add
  Input text                          jquery=textarea#tender_question_answer            ${answer}
  Click Element                       jquery=input[value="Зберегти"]
  Sleep                               5
  Reload page
  Click Element                       jquery=a[aria-controls="discussion-collapse"]
  Wait Until Page Contains            ${answer}   30
  Capture Page Screenshot
  Log to console                      [ INFO ] : Відповідь дано



Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tender_id
  ...      ${ARGUMENTS[2]} = field // description
  ...      ${ARGUMENTS[3]} = new value
  Log to console                          \n[ INFO ] : Внести зміни в тендер
  tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                                ${ARGUMENTS[1]}
  Click Element                           jquery=a.tender_edit
  tabtenders.Run test session
  Sleep                                   2
  Input text                              jquery=textarea#tender_description                                  ${ARGUMENTS[3]}
  Click Element                           jquery=input.send_to_prozorro
  Log to console                          \n[ INFO ] : Опублікувати зміни
  Sleep                                   1



Подати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  ${test_bid_data}
    Log to console                          \n[ INFO ] : Подати цінову пропозицію

    ${amount}=    Get From Dictionary     ${ARGUMENTS[2].data.value}    amount
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    sleep   10
    tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                                ${ARGUMENTS[1]}
    Sleep   180
    Reload page
    Click Element       jquery=a.bid_add
    Input Text          jquery=input#tender_bid_value_attributes_amount         ${amount}
    sleep   2
    Click Element       jquery=input[value="Додати"]
    sleep   30
    Reload page
    Capture page screenshot

    ${value}=   Get Element Attribute      jquery=a.btn_delete@data-target
    ${resp}=    getBidID                   ${value}
    Log to console                         [ INFO ] : Bid ID: ${resp}

    [Return]    ${resp}



Скасувати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    Log to console                        \n[ INFO ] : Скасувати цінову пропозицію
    Log to console                        "@{ARGUMENTS}"


    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    sleep   10
    tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                                ${ARGUMENTS[1]}
    Sleep   5
    Click Element   jquery=a.btn_delete
    sleep   2
    Wait Until Page Contains Element      jquery=a.bid_delete     30
    Click Element   jquery=a.bid_delete
    Reload page
    Sleep   5
    Capture page screenshot



Змінити цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  amount
    ...    ${ARGUMENTS[3]} ==  amount.value
    Log to console                     \n[ INFO ] : Змінити цінову пропозицію
    Log to console                     "@{ARGUMENTS}"

    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element                      jquery=a.bid_edit
    Clear Element Text                 jquery=input#tender_bid_value_attributes_amount
    Input Text                         jquery=input#tender_bid_value_attributes_amount         ${ARGUMENTS[3]}
    Sleep                              3
    Click Element                      jquery=a[value="Зберегти"]
    Sleep                              10
    Reload page
    Capture page screenshot



Завантажити документ в ставку
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId

    Log to console                          \n[ INFO ] : Завантажити документ в ставку
    Log to console                          "@{ARGUMENTS}"

    tabtenders.Run test session


    Sleep   5
    Click Element                           jquery=a.bid_edit
    Sleep   2

    Choose File                             jquery=input[type="file"]                       ${ARGUMENTS[1]}
    Sleep                                   3
    Click Element                           jquery=input.send_to_prozorro
    Log to console                          [ INFO ] : Документ завантажено
    Sleep                                   10
    Reload page
    Capture page screenshot



Змінити документ в ставці
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId
    Log to console                          \n[ INFO ] : Завантажити документ в ставку
    Log to console                          "@{ARGUMENTS}"

    tabtenders.Завантажити документ в ставку   @{ARGUMENTS}



Отримати посилання на аукціон для глядача
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId

    Log to console                        \n[ INFO ] : Отримати посилання на аукціон для глядача
    Log to console                        "@{ARGUMENTS}"

    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to                                 ${USERS.users['${ARGUMENTS[0]}'].homepage}
    Sleep                                 10

    tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                ${ARGUMENTS[1]}
    Reload page
    ${result}=   Get Element Attribute      jquery=a.btn_auction@href

    [Return]   ${result}



Отримати посилання на аукціон для учасника
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId

    Log to console                        \n[ INFO ] : Отримати посилання на аукціон для учасника
    Log to console                        "@{ARGUMENTS}"

    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to                                 ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep                                 10

    tabtenders.Пошук тендера по ідентифікатору                ${ARGUMENTS[0]}                ${ARGUMENTS[1]}
    Reload page
    ${result}=   Get Element Attribute      jquery=a.btn_participation_auction@href

    [Return]   ${result}



Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Log to console                      \n[ INFO ] : Отримати інформацію з тендера
  Log to console                      "@{ARGUMENTS}"
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[1]}
  Log to console     [ INFO ] : ... ${return_value}
  [Return]  ${return_value}



Find information on page
  [Arguments]   ${fieldname}
  ${return_value}=   ${locator.${fieldname}}
  Log to console     [ INFO ] : Found ${fieldname} on page 
  [Return]  ${return_value}



Отримати інформацію про title
  ${return_value}=   Find information on page   title
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про description
  ${return_value}=   Find information on page   description
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про value.amount
  ${return_value}=   Find information on page  value.amount
  ${return_value}=   Get Text                   ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про value.currency
  Log to console        UAH only
  [Return]  UAH



Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Find information on page   value.tax
  ${return_value}=   Get Text                   ${return_value}
  ${return_value}=   checkTaxIncluded           ${return_value}
  [Return]  ${return_value}



Отримати інформацію про tenderID
  ${return_value}=   Find information on page   tenderId
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про procuringEntity.name
  ${return_value}=   Find information on page   procuringEntity.name
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про enquiryPeriod.startDate
  Log to console        Viewer can't see this information



Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Find information on page   enquiryPeriod.endDate
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про tenderPeriod.startDate
  Log to console        Viewer can't see this information



Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Find information on page  tenderPeriod.endDate
  ${return_value}=   Get Text                   ${return_value}

  [Return]    ${return_value}



Отримати інформацію про minimalStep.amount
  ${return_value}=   Find information on page   minimalStep.amount
  ${return_value}=   Get Text                   ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [Return]   ${return_value}




Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=   Find information on page  items[0].deliveryDate.endDate
  ${return_value}=   Get Text                   ${return_value}

  [Return]    ${return_value}



Отримати інформацію про items[0].deliveryLocation.longitude
  Log to console        Viewer can't see this information



Отримати інформацію про items[0].deliveryLocation.latitude
  Log to console        Viewer can't see this information



Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=   Find information on page  items[0].deliveryAddress.countryName
  ${return_value}=   Get Text                   ${return_value}

  [Return]      ${return_value}



Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=   Find information on page  items[0].deliveryAddress.postalCode
  ${return_value}=   Get Text                   ${return_value}

  [Return]      ${return_value}



Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=   Find information on page  items[0].deliveryAddress.region
  ${return_value}=   Get Text                   ${return_value}

  [Return]   ${return_value}



Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=   Find information on page  items[0].deliveryAddress.locality
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=   Find information on page  items[0].deliveryAddress.streetAddress
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про items[0].classification.scheme
  Log to console        Viewer can't see this information



Отримати інформацію про items[0].classification.id
  ${return_value}=   Find information on page  items[0].classification.id
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про items[0].classification.description
  ${return_value}=   Find information on page  items[0].classification.description
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про items[0].additionalClassifications[0].scheme
  Log to console        Viewer can't see this information



Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Find information on page  items[0].additionalClassifications[0].id
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=   Find information on page  items[0].additionalClassifications[0].description
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про items[0].unit.name
  ${return_value}=   Find information on page   jquery=span.quantity_name
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}



Отримати інформацію про items[0].unit.code
  ${return_value}=   Get Element Attribute      jquery=span.quantity_name@data-unit_code
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}




Отримати інформацію про items[0].quantity
  ${return_value}=   Find information on page   items[0].quantity
  ${return_value}=   Get Text                   ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [Return]  ${return_value}



Отримати інформацію про items[0].description
  ${return_value}=   Find information on page   items[0].description
  ${return_value}=   Get Text                   ${return_value}

  [Return]  ${return_value}








# Відображення заголовку анонімного питання без відповіді
#   [Tags]   ${USERS.users['${viewer}'].broker}: Відображення запитання
#   ...      viewer
#   ...      ${USERS.users['${viewer}'].broker}
#   ...      level2
#   [Setup]  Дочекатись синхронізації з майданчиком  ${viewer}
#   Викликати для учасника  ${viewer}  Оновити сторінку з тендером  ${TENDER['TENDER_UAID']}
#   Звірити поле тендера із значенням  ${viewer}
#   ...      ${USERS.users['${provider}'].question_data.question.data.title}  title
#   ...      object_id=${USERS.users['${provider}'].question_data.question_id}


# Відображення опису анонімного питання без відповіді
#   [Tags]   ${USERS.users['${viewer}'].broker}: Відображення запитання
#   ...      viewer
#   ...      ${USERS.users['${viewer}'].broker}
#   ...      level2
#   Звірити поле тендера із значенням  ${viewer}
#   ...      ${USERS.users['${provider}'].question_data.question.data.description}  description
#   ...      object_id=${USERS.users['${provider}'].question_data.question_id}


# Відображення дати анонімного питання без відповіді
#   [Tags]   ${USERS.users['${viewer}'].broker}: Відображення запитання
#   ...      viewer
#   ...      ${USERS.users['${viewer}'].broker}
#   Звірити дату тендера із значенням  ${viewer}
#   ...      ${USERS.users['${provider}'].question_data.question.data.date}  date
#   ...      object_id=${USERS.users['${provider}'].question_data.question_id}


# Відображення відповіді на запитання
#   [Tags]   ${USERS.users['${viewer}'].broker}: Відображення відповіді на запитання
#   ...      viewer
#   ...      ${USERS.users['${viewer}'].broker}
#   ...      level2
#   [Setup]  Дочекатись синхронізації з майданчиком  ${viewer}
#   Викликати для учасника  ${viewer}  Оновити сторінку з тендером  ${TENDER['TENDER_UAID']}
#   Звірити поле тендера із значенням  ${viewer}
#   ...      ${USERS.users['${provider}']['answer_data']['answer'].data.answer}  answer
#   ...      object_id=${USERS.users['${provider}'].question_data.question_id}


Отримати інформацію про status
  reload page
  ${return_value}=   Find information on page   status
  ${return_value}=   Get Text                   ${return_value}
  [Return]  ${return_value}



