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
    <br/>
    <h2>Periodo IVA ${ year() }</h2>
    % set total = {'credit': [0.0], 'debit': [0.0], 'extra': [0.0]}
    % set total_vat = [0.0]
    % set total_base = [0.0]
    % for type in ('credit', 'debit', 'extra'):
        <h3 class="type">${ type=='credit' and 'Acquisti' or type=='extra' and 'Altri crediti / debiti per IVA o compensazioni di imposta' or 'Vendite' }</h3>
        <table class="table table-bordered table-condensed">
            <thead>
                <tr>
                    <th style="width:50%;">Descrizione</th>
                    <th style="width:25%;">Imponibile</th>
                    <th style="width:25%;">Imposta</th>
                </tr>
            </thead>
            <tbody> 
		        % set total_base = [0.0]
                % set total_vat = [0.0]
                % set taxes = tax_codes_amounts(type)
                % set multiplier = type=='credit' and -1 or 1
                % for tax,vals in taxes.items():
                <tr>
                    <td>${ tax }</td>
                    <td class="align-right">${ '{:,.2f}'.format(vals['base']*multiplier) }</td>
                    <td class="align-right">${ '{:,.2f}'.format(vals['vat']*multiplier) }</td>
                </tr>
                  % if total_base.append(vals['base']*multiplier)
    		  % endif
                  % if total_vat.append(vals['vat']*multiplier)
    		  % endif
                  % if total[type].append(vals['vat']*multiplier)
                  % endif
                % endfor
                <tr>
                    <td></td>
                    <td class="total align-right">${ '{:,.2f}'.format(total_base|sum) }</td>
                    <td class="total align-right">${ '{:,.2f}'.format(total_vat|sum) }</td>
                </tr>
            </tbody>
        </table>
    % endfor
    <table class="table table-bordered table-condensed" style="margin-left:50%;width:50%;">
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
