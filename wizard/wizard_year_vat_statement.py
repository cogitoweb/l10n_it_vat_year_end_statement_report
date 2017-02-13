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


from openerp.osv import orm, fields


class wizard_year_statement(orm.TransientModel):

    _name = 'wizard.year.statement'

    _columns = {
        'fiscalyear_id': fields.many2one('account.fiscalyear', 'Fiscalyear',
                                         required=True)
        }

    def print_report(self, cr, uid, ids, context={}):
        wizard = self.browse(cr, uid, ids, context)[0]
        res = {
            'type': 'ir.actions.report.xml',
            'datas': {'ids': ids,
                      'model': 'account.move',
                      'fiscalyear_id': wizard.fiscalyear_id.id,
                      'year': wizard.fiscalyear_id.name,
                      },
            'report_name': 'vat.year.end.statement',
        }
        return res