pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

    library DMTOwned{
  
    struct Owned {
        uint256 r;
        uint256 t;
        bool isExcluded ;
        bool isWhitelisted;
    }

    function burn(Owned storage self, uint256 amount, uint256 accountBalance ) public {
        require(accountBalance >= amount, "ERC20: Amount exceeds balance");
        if (self.isExcluded){ self.t = accountBalance - amount; }
        else { self.r = accountBalance - amount; } 
    }

    function balanceOf(Owned storage self, uint256 rate) public view returns (uint256) {
        if (self.isExcluded) return self.t;
        return self.r / rate;
    }

    function includeAccount(Owned storage self , address[] storage excluded , address account ) public returns (address[] storage)  {
        require(self.isExcluded, "Account already excluded");
        for (uint256 i = 0; i < excluded.length; i++) {
            if (excluded[i] == account) {
                excluded[i] = excluded[excluded.length - 1];
                self.t = 0;
                self.isExcluded = false;
                excluded.pop();
                break;
            }
        }
        return excluded;
    }

    function excludeAccount(Owned storage self , address[] storage excluded , address account, uint256 rate ) public returns (address[] storage)  {
        
        if(self.r > 0) {
            self.t = self.r/rate;
        }
        self.isExcluded = true;
        excluded.push(account);
        return excluded;
    }

    function reflectBurn(Owned storage self,uint256 tBurn , uint256 rate) public {
        self.r = self.r + (tBurn * rate);
        if(self.isExcluded)
            self.t = self.t + tBurn;
    }

    function reflectPerformanceFee(Owned storage self,uint256 tPerformanceFee,uint256 rate) internal {
        self.r = self.r + (tPerformanceFee * rate);
        if(self.isExcluded)
            self.t = self.t + tPerformanceFee;
    }

    function reflectLiquidity(Owned storage self, uint256 tLiquidityFee, uint256 rate) internal {  
        self.r +=(tLiquidityFee * rate);
        if(self.isExcluded)
            self.t +=tLiquidityFee;
    }
}