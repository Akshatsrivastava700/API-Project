
async function setup(){
  let options = {
  			method: 'GET',
  			header: {
          "Access-Control-Allow-Origin" : "*"
  			}
  		}
  const response = await fetch("http://localhost:4567/stay_weekend_nights_per_month", options)
  var data = await response.json();

  Highcharts.chart('container', {
    chart: {
        type: 'column',
        options3d: {
            enabled: true,
            alpha: 10,
            beta: 25,
            depth: 90
        }
    },
    title: {
        text: 'Weekend Stays'
    },

    plotOptions: {
        column: {
            depth: 30
        }
    },
    xAxis: {
      categories: Object.keys(data)
    },

    yAxis: {
        title: {
            text: "Percentage(%)"
        }
    },

    series: [{
        name: 'Months',
        data: Object.values(data)
    }]

});
}

setup()
