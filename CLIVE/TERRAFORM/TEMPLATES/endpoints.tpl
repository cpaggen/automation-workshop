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
          <th>Endpoint DN</th>
          <th>VLAN</th>
          <th>IP addresses</th>
          <th>MAC address</th>
        </tr>

        {% for ep in endpoints %}
        <tr>
        <td>{{ ep['fvCEp']['attributes']['dn'] }}</td>
        <td>{{ ep['fvCEp']['attributes']['encap'] }}</td>
        <td>{{ ep['fvCEp']['attributes']['ip'] }}</td>
        <td>{{ ep['fvCEp']['attributes']['mac'] }}</td>
        </tr>
        {% endfor %}
        </td>
        </table>
    </body>
</html>