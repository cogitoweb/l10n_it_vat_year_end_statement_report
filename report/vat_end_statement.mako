<html>
<head>
    <style type="text/css">
        ${css}
    </style>
</head>
<body>
    <h2>Liquidazione IVA Annuale - ${ year() }</h2>
    % set total = {'credit': [0.0], 'debit': [0.0]}
    % set total_vat = [0.0]
    % set total_base = [0.0]
    % for type in ('credit', 'debit'):
        <h3 class="type">${ type=='credit' and 'Acquisti' or 'Vendite' }</h3>
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
                % for tax,vals in taxes.items():
                <tr>
                    <td>${ tax }</td>
                    <td>${ vals['base'] }</td>
                    <td>${ vals['vat'] }</td>
                </tr>
                  % if total_base.append(vals['base'])
    		  % endif
                  % if total_vat.append(vals['vat'])
    		  % endif
                  % if total[type].append(vals['vat'])
                  % endif
                % endfor
                <tr>
                    <td></td>
                    <td class="total">${ total_base|sum }</td>
                    <td class="total">${ total_vat|sum }</td>
                </tr>
            </tbody>
        </table>
    % endfor
    <table class="table table-bordered table-condensed" style="margin-left:50%;width:50%;">
        <tr>
            <td style="width:50%;">Iva Debito</td>
            <td style="width:50%;">${ total['debit']|sum }</td>
        </tr>
        <tr>
            <td>Iva Credito</td>
            <td>${ total['credit']|sum }</td>
        </tr>
        <tr>
            <td>Da Versare</td>
            <td>${ total['debit']|sum + total['credit']|sum }</td>
        </tr>
    </table>
</body>
</html>
