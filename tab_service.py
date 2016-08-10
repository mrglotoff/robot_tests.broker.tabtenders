# -*- coding: utf-8 -*-
import dateutil.parser
import random
from datetime import datetime

def adapt_minimalStep(tender_data):
    # Modify amount with new percentage
    value_amount = tender_data['value']['amount']
    percentage = random.uniform(0.005, 0.03)

    tender_data['minimalStep']['amount'] = round(percentage * value_amount, 2)
    return percentage * 100

def getTenderDates(initial_tender_data, key):
    tender_period = initial_tender_data.data.tenderPeriod
    data = {
        'endPeriod': parseDates(tender_period['startDate']),
        'endDate': parseDates(tender_period['endDate']),
    }
    return data.get(key, '')

def parseDates(period):
    return dateutil.parser.parse(period).strftime("%d.%m.%Y")

def chooseUnit(unitCode):
    return "li[data-value=\"{}\"]".format(unitCode)

def getTenderID(obj):
    return obj.capitalize()

def tenderAmountType(amount):
    return "li.select_tender_{}".format(1 if amount <= 50000 else 2)

def lotAmountType(lots):
    return "li.lots_type_{}".format(1 if len(lots) == 1 else 2)

  # log to console                          \nTender title: ${title}\n


# def get_delivery_date_prom(initial_tender_data):
#     delivery_end_date = initial_tender_data.data['items'][0]['deliveryDate']['endDate']
#     endDate = dateutil.parser.parse(delivery_end_date)
#     return endDate.strftime("%d.%m.%Y")


# def return_delivery_endDate(initial_tender_data, input_date):
#     init_delivery_end_date = initial_tender_data.data['items'][0]['deliveryDate']['endDate']
#     if input_date in init_delivery_end_date:
#         return init_delivery_end_date
#     else:
#         return input_date


# def convert_date_prom(isodate):
#     return datetime.strptime(isodate, "%d.%m.%y %H:%M").isoformat()


# def convert_date_to_prom_tender_startdate(isodate):
#     first_date = isodate.split(' - ')[0]
#     first_iso = datetime.strptime(first_date, "%d.%m.%y %H:%M").isoformat()
#     return first_iso


# def convert_date_to_prom_tender_enddate(isodate):
#     second_date = isodate.split(' - ')[1]
#     second_iso = datetime.strptime(second_date, "%d.%m.%y %H:%M").isoformat()
#     return second_iso


# def convert_prom_string_to_common_string(string):
#     return {
#         u"кілограми": u"кілограм",
#         u"кг.": u"кілограми",
#         u"грн.": u"UAH",
#         u" з ПДВ": True,
#         u"Картонки": u"Картонні коробки",
#         u"Період уточнень": u"active.enquiries",
#         u"Прийом пропозицій": u"active.tendering",
#         u"Аукціон": u"active.auction",
#     }.get(string, string)

# def adapt_item(tender_data):
#     tender_data['data']['items'][0]['unit']['name'] = u"килограммы"
#     return tender_data


# def adapt_test_mode(tender_data):
#     try:
#         del tender_data['data']['mode']
#     except KeyError:
#         pass
#     return tender_data

