# -*- coding: utf-8 -*-
import dateutil.parser
import random
from datetime import datetime, timedelta


def getTenderDates(initial_tender_data, key):
    tender_period = initial_tender_data.data.tenderPeriod
    data = {
        'endPeriod': parseDates(tender_period['startDate']),
        'endDate': parseDates(tender_period['endDate']),
        'deliveryStartDate': (dateutil.parser.parse(tender_period['endDate']) + timedelta(days=1)).strftime("%d.%m.%Y")
    }
    return data.get(key, '')

def parseDates(period):
    return dateutil.parser.parse(period).strftime("%d.%m.%Y %H:%M")

def chooseUnit(unitCode):
    return "li[data-value=\"{}\"]".format(unitCode)

def tenderAmountType(amount):
    return "li.select_tender_{}".format(1 if amount <= 50000 else 2)

def lotAmountType(lots):
    return "li.lots_type_{}".format(1 if len(lots) == 1 else 2)

def checkTaxIncluded(text):
    return text.replace('(', '').raplce(')') == 'з ПДВ'

def getBidID(obj):
    return obj.split('bid/')[-1]

def adaptProcuringEntity(tender_data):
    tender_data['data']['procuringEntity']['name'] = u'TestCompany'
    return tender_data
