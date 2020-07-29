<html>
    <head>
        <title>{{ title }}</title>
         <link rel="stylesheet" type= "text/css" href="{{ url_for('static', filename='/styles/stylesheet.css') }}"/>
    </head>
    <body>
     <ul>
      <li><a class="active" href="/tenants">Tenants</a></li>
      <li><a href="/epgs">EPGs</a></li>
      <li><a href="/endpoints">Endpoints</a></li>
      <li><a href="/terraform">Terraform</a></li>
    </ul>
    <table>
      <td>
        <tr>
        <th>EPGs DNs</th>
        </tr>
        {% for epg in epgs %}
        <tr>
        <td>{{ epg['fvAEPg']['attributes']['dn'] }}</td>
        </tr>
        {% endfor %}
        </td>
        </table>
    </body>
</html>