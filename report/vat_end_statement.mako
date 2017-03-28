<html>
<head>
    <style type="text/css">
        ${css}
        
        .align-right {
            text-align: right;
        }
    </style>
</head>
<body>
    <br />
    <h2>Periodo IVA ${ year() }</h2>
    % set total = {'credit': [0.0], 'debit': [0.0], 'extra': [0.0]}
    % set total_vat = [0.0]
    % set total_base = [0.0]
    % set total_d = [0.0]
    % set total_und = [0.0]
    % for type in ('credit', 'debit', 'extra'):
        <h3 class="type">${ type=='credit' and 'Acquisti' or type=='extra' and 'Altri crediti / debiti per IVA o compensazioni di imposta' or 'Vendite' }</h3>
        <table class="table table-bordered table-condensed">
            <thead>
                <tr>
                    <th style="width:10%;">Codice</th>
                    <th style="width:41%;">Descrizione</th>
                    <th style="width:13%;">Imponibile</th>
                    <th style="width:13%;">${ type=='credit' and 'Imposta' or '' }</th>
                    <th style="width:13%;">Detraibile</th>
                    <th style="width:13%;">${ type=='credit' and 'Indetraibile' or '' }</th>
                </tr>
            </thead>
            <tbody> 
		% set total_base = [0.0]
                % set total_vat = [0.0]
                % set taxes = tax_codes_amounts(type)
                % set taxes_keys = taxes[0]
                % set vals = taxes[1]
                % for k in taxes_keys:
                <tr>
                    <td>${ vals[k]['code'] }</td>
                    <td>${ vals[k]['name'] }</td>
                    <td class="align-right">${ '{:,.2f}'.format(vals[k]['base']|abs) }</td>
                    <td class="align-right">${ type=='credit' and '{:,.2f}'.format(vals[k]['d']|abs) or '' }</td>
                    <td class="align-right">${ '{:,.2f}'.format(vals[k]['vat']|abs) }</td>
                    <td class="align-right">${ type=='credit' and '{:,.2f}'.format(vals[k]['und']|abs) or '' }</td>
                </tr>
                  % if total_base.append(vals[k]['base']|abs)
    		  % endif
                  % if total_vat.append(vals[k]['vat']|abs)
    		  % endif
                  % if total_d.append(vals[k]['d']|abs)
    		  % endif
                  % if total_und.append(vals[k]['und']|abs)
    		  % endif
                  % if total[type].append(vals[k]['vat']|abs)
                  % endif
                % endfor
                <tr>
                    <td></td>
                    <td></td>
                    <td class="total align-right">${ '{:,.2f}'.format(total_base|sum) }</td>
                    <td class="total align-right">${ type=='credit' and '{:,.2f}'.format(total_d|sum) or '' }</td>
                    <td class="total align-right">${ '{:,.2f}'.format(total_vat|sum) }</td>
                    <td class="total align-right">${ type=='credit' and '{:,.2f}'.format(total_und|sum) or '' }</td>
                </tr>
            </tbody>
        </table>

         % if type=='debit'
         <div style="page-break-after: always;"><br /><br /></div>
         % endif

    % endfor

    <table class="table table-bordered table-condensed nobreak" style="margin-left:50%;width:50%;">
        <tr>
            <td style="width:50%;">Iva Debito</td>
            <td style="width:50%;"  class="align-right">${ '{:,.2f}'.format(total['debit']|sum) }</td>
        </tr>
        <tr>
            <td>Iva Credito</td>
            <td class="align-right">${ '{:,.2f}'.format(total['credit']|sum) }</td>
        </tr>
        <tr>
            <td>Compensazioni</td>
            <td class="align-right">${ '{:,.2f}'.format(total['extra']|sum*-1) }</td>
        </tr>
        <tr>
            <td><strong>Da Versare</strong></td>
            <td class="align-right"><strong>${ '{:,.2f}'.format(total['debit']|sum - total['credit']|sum + total['extra']|sum*-1) }</strong></td>
        </tr>
    </table>
</body>
</html>
