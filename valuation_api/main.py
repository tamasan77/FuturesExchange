from flask import Flask
from flask_restful import Api, Resource
import datetime
from datetime import timezone, timedelta
import math

app = Flask(__name__)
api = Api(app)

class Valuate():
    def value_forward(init_price, val_date, exp_date, underlying_price, risk_free_rate):
        """
        * @dev f(t) = S(t) - F * EXP(-r(T-t))
        * f(t) :: Long Forward Value
        * F :: Forward Price at initation
        * t :: Valuation Date
        * T :: Expiration Date
        * T-t :: seconds between the valuation date and expiration date
        * S(t) :: underlying asset price on the valuation date
        * r(t) :: continuosly compounded risk free interest rate on the valuation date d
        """
        t_delta_seconds = (exp_date - val_date)
        #annual_risk_free_rate = 0.07
        #risk_free_rate_second = ((annual_risk_free_rate / 365) / 86400)
        ft = underlying_price - init_price * math.e ** (-risk_free_rate*t_delta_seconds)
        return ft

    def price_forward(underlying_price, annual_risk_free_rate, valuation_date, expiration_date):
        """
        * @dev F(t) = S(t) * EXP(r(T-t))
        * F(t): forward price
        * t : valuation date
        * T : expiration date
        * T-t: seconds between valuation and expiration date
        * S(t): underlying asset price at valuation date
        * r(t): continuously compounded risk free interest rate on the valuation date
        """
        t_delta_seconds = (expiration_date - valuation_date)
        risk_free_rate = ((annual_risk_free_rate / 365) / 86400)
        forward_price = underlying_price * math.e ** (risk_free_rate * t_delta_seconds)
        return forward_price



class Pricing(Resource):
    """
    def get(self, init_price, val_date, exp_date, current_price, risk_free_rate):
        ffaValue = Valuate.value_forward(init_price, val_date, exp_date, current_price, risk_free_rate)
        return {"value" : ffaValue}
    """
    def get(self, underlying_price, annual_risk_free_rate, valuation_date, expiration_date):
        ffaPrice = Valuate.price_forward(underlying_price, annual_risk_free_rate, valuation_date, expiration_date)
        return {"price" : ffaPrice}

"""
* Questions left:
* Resolve solidity being unable to pass on floating point numbers
* Pass on int and info about decimals and convert back to float
"""
#api.add_resource(Pricing, "/valuate/<float:init_price>/<int:val_date>/<int:exp_date>/<float:current_price>/<float:risk_free_rate>")
api.add_resource(Pricing, "/price/<float:underlying_price>/<float:annual_risk_free_rate>/<int:valuation_date>/<int:expiration_date>")

if __name__ == "__main__":
    app.run(debug=True)