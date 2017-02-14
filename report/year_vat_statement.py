# -*- coding: utf-8 -*-
##############################################################################
#
#    Copyright (C) 2014 Apulia Sofware s.r.l (<info@apuliasoftware.it>)
#    All Rights Reserved
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published
#    by the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################


import time
from openerp.report import report_sxw
from openerp.addons.report_webkit import webkit_report
from openerp.osv import osv
from openerp.tools.translate import _
#Import logger
import logging

_logger = logging.getLogger(__name__)

class Parser(report_sxw.rml_parse):
#class Parser(webkit_report):

    def _build_codes_dict(self, tax_code, res=None, context=None):
        if res is None:
            res = {}
        if context is None:
            context = {}
        tax_pool = self.pool['account.tax']
        
        if tax_code.sum:
            if res.get(tax_code.name, False):
                raise osv.except_osv(
                    _('Error'),
                    _('Too many occurences of tax code %s') % tax_code.name)
            # search for taxes linked to that code
            tax_ids = tax_pool.search(
                self.cr, self.uid, [
                    ('tax_code_id', '=', tax_code.id)], context=context)
            if tax_ids:
                tax = tax_pool.browse(
                    self.cr, self.uid, tax_ids[0], context=context)
                # search for the related base code
                base_code = (
                    tax.base_code_id or tax.parent_id
                    and tax.parent_id.base_code_id or False)
                if not base_code:
                    raise osv.except_osv(
                        _('Error'),
                        _('No base code found for tax code %s')
                        % tax_code.name)
                # check if every tax is linked to the same tax code and base
                # code
                for tax in tax_pool.browse(
                        self.cr, self.uid, tax_ids, context=context):
                    test_base_code = (
                        tax.base_code_id or tax.parent_id
                        and tax.parent_id.base_code_id or False)
                    if test_base_code.id != base_code.id:
                        raise osv.except_osv(
                            _('Error'),
                            _('Not every tax linked to tax code %s is linked '
                              'the same base code') % tax_code.name)
                res[tax_code.name] = {
                    'vat': tax_code.sum,
                    'base': base_code.sum,
                }
            for child_code in tax_code.child_ids:
                res = self._build_codes_dict(
                    child_code, res=res, context=context)
        return res

    def _get_tax_codes_amounts(self, type='credit',
                               tax_code_ids=None, context={}):
        tax_code_pool = self.pool['account.tax.code']
        
        context['fiscalyear_id'] = self.localcontext['data']['fiscalyear_id']
        context['year'] = self.localcontext['data']['year']
        context['compensation_ids'] = self.localcontext['data']['compensation_ids']
        
        tax_code_ids = tax_code_ids or []
        if not len(tax_code_ids):
            
            # standard groups for credit and debit
            if type in ('credit', 'debit'):
                
                params = [
                    ('vat_statement_account_id', '!=', False),
                    ('vat_statement_type', '=', type),
                    ]
                
                # add compensation even in debit and credit
                #
                ##if context['compensation_ids']:
                ##    params.append(('id', 'not in', context['compensation_ids']));
                
                tax_code_ids = tax_code_pool.search(self.cr, self.uid, params, context=context)
            # extra groups
            elif type in ('extra') and context['compensation_ids']:
                
                #_logger.info('EXTRA %s', "-".join(context['compensation_ids']))
                
                tax_code_ids = tax_code_pool.search(self.cr, self.uid, [
                    ('id', 'in', context['compensation_ids'])
                    ], context=context)
                
        res = {}
        code_pool = self.pool['account.tax.code']
        
        for tax_code in code_pool.browse(
                self.cr, self.uid, tax_code_ids, context=context):
            res = self._build_codes_dict(tax_code, res=res, context=context)
        return res

    def get_year(self, context={}):
        return self.pool['account.fiscalyear'].browse(
            self.cr, self.uid,
            self.localcontext['data']['fiscalyear_id']).name

    def __init__(self, cr, uid, name, context=None):
        if context is None:
            context = {}
        super(Parser, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'tax_codes_amounts': self._get_tax_codes_amounts,
            'year': self.get_year,
            })
        self.context = context

#report_sxw.report_sxw(
webkit_report.WebKitParser(
    'report.vat.year.end.statement',
    'account.move',
    'addons/year_vat_period_and_statement/report/'
    'year_vat_statement.mako',
    parser=Parser)
