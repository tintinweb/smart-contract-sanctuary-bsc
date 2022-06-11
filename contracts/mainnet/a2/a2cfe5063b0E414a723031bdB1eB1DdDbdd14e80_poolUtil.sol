//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.0;
import "../Interfaces.sol";

// import "hardhat/console.sol";
///@title poolUtil.sol
///@author Derrick Bradbury ([email protected])
///@dev Library to handle staked pool and distribute rewards amongst stakeholders
library poolUtil {
    event addFunds_evt(address _user, uint _amount);
    event requestFunds_evt(uint _amount);
    event sendFunds_evt(address _to, uint _amount);
    event sendHoldback_evt(address _to, uint _amount);
    event distContrib_evt(address _to_, uint _units, uint _amount, uint _feeAmount);
    event distContribTotal_evt(uint _total, uint _amount);
    event commitFunds_evt(uint _amount);
    event liquidateFunds_evt(uint _total, uint _amount);
    event returnDeposits_evt(uint _total, uint _amount);
    event Swap(address _from, address _to, uint amountIn, uint amountOut);

    event sdLiquidityProvided(uint256 amount0, uint256 amount1, uint256 lpOut);
    error sdInsufficentFunds();

    ///@notice Add funds to a held pool from a user
    ///@param _self stHolders structure from main contract
    ///@param _amount amount to add for user into staking
    ///@dev Emits addFunds_evt to notify funds being added
    function addFunds(stData storage _self, stHolders storage _holders, uint _amount, address _user) internal {
        require(!_self.paused,"Deposits are Paused");
        if(_holders.iHolders[_user].depositDate == 0) {
            _holders.iQueue.push(_user);
            _holders.iHolders[_user]._pos = _holders.iQueue.length-1;
        }
        
        transHolders memory _tmp;
        _tmp.amount = _amount;
        _tmp.account = _user;
        _tmp.timestamp = block.timestamp;

        _holders.dHolders.push(_tmp);
        _holders.dQueue[_user].push(_holders.dHolders.length-1);
        _holders.iHolders[_user].depositDate = block.timestamp>_self.lastProcess?block.timestamp:_self.lastProcess; //set users last deposit date
        _holders.iHolders[_user].amount += _amount; // Increment users account
        
        _self.depositTotal += _amount;

        emit addFunds_evt(_user, _amount);
    }
    ///@notice Request funds from a held pool
    ///@dev Overloads addFunds to request funds from a held pool without adding the user
    ///@param _self stHolders structure from main contract
    ///@param _amount amount to request from staking pool
    ///@return Amount passed in

    function requestFunds(stData storage _self, stHolders storage _holders, uint _amount) internal returns (uint) {
        return requestFunds(_self, _holders, msg.sender, _amount);
    }

    ///@notice User can request funds to be withdrawn, amount put into queue
    ///@param _self stHolders structure from main contract
    ///@param _amount of stake amount to be sent back for user
    ///@dev Emits requestFunds_evt to notify funds being added
    ///@dev if 0 amount is passed in, all requests for user are removed
    function requestFunds(stData storage _self, stHolders storage _holders,address _user, uint _amount) internal returns (uint _returnAmount) {
        require(!_self.paused,"Withdrawals are Paused");
        require(_amount <= _holders.iHolders[_user].amount,"Insufficent Funds");
        if (_amount == 0) _amount = _holders.iHolders[_user].amount;
        transHolders memory _tmp;
        _tmp.amount = _amount;
        _tmp.account = _user;
        _tmp.timestamp = block.timestamp;
        _holders.wHolders.push(_tmp);
        uint wholder_len = _holders.wHolders.length;
        _holders.wQueue[_user].push(wholder_len-1);
        _holders.iHolders[_user].amount -= _amount;
        _self.withdrawTotal += _amount;

        _returnAmount = _amount;
        emit requestFunds_evt(_amount);
    }

    ///@notice Function calculates share percentage for particular user
    ///@param _self stHolders structure from main contract
    ///@param _user address of user to calculate
    ///@return _units - returns units based on current blance and total deposits and withdrawals
    function calcUnits(stData storage _self, stHolders storage _holders, address _user) internal view returns (uint _units) {        
        uint _time = block.timestamp - _self.lastProcess; // time since last harvest
        uint _amt = _holders.iHolders[_user].amount * _time; // Users Balance, amount contains total deposits
        uint _pt = _self.poolTotal * _time; // Pool Total
        
        uint _dAmt; // Amount of deposits
        
        for (uint d = 0; d < _holders.dHolders.length; d++) {     
            if (_holders.dHolders[d].timestamp == 0) continue;       
            uint _dTime = _holders.dHolders[d].timestamp - _self.lastProcess; //difference between deposit and last harvest
            uint _tmpAmount = _holders.dHolders[d].amount; // the amount of the deposit
            uint _tAmt = _tmpAmount * (_dTime>0 ? _time - _dTime : _time);
            
            _dAmt += _tAmt; //add to total amount of deposits

            if (_holders.dHolders[d].account == _user) {
                uint _cAmt = (_tmpAmount * _time) - _tAmt;
                _amt = _amt > 0 ? (_amt < _cAmt ? _amt : _amt - _cAmt) : _tAmt; // if committed balance > 0 credit user for time deposited only        
            }
        }

        uint _wAmt; // Amount of withdrawals
        for (uint w = 0; w < _holders.wHolders.length; w++) {
            if (_holders.wHolders[w].timestamp == 0) continue;       
            uint _wTime = (_holders.wHolders[w].timestamp - _self.lastProcess);
            uint _tAmt = _holders.wHolders[w].amount * (_wTime>0 ? _wTime : _time);
            if (_pt >= _tAmt) _pt -=  _tAmt;
            _wAmt += _tAmt;

            if (_holders.wHolders[w].account == _user) {
                _amt += _tAmt; // credit user amount before withdrawal
            }
        }

        uint _total = (_pt + _dAmt + _wAmt);
        _units = _total > 0 ? (_amt*10**18) / _total : 0;
    }

    /// @notice Add all deposits to accountholder
    /// @param _self stHolders structure from main contract
    function commitDeposits(stData storage _self, stHolders storage _holders) private {
        for (uint i = _holders.dHolders.length; i > 0; i--) {            
            address _user = _holders.dHolders[i-1].account;

            _holders.iHolders[_user].depositDate = block.timestamp;
            _self.depositTotal -= _holders.dHolders[i-1].amount;
            _self.poolTotal += _holders.dHolders[i-1].amount;
        }
        clearDepositsQueue(_holders,address(0));
    }

    ///@notice Clear out deposits for a specific user
    ///@param _self stHolders structure from main contract
    ///@param _user address of user to clear
    function clearDeposits(stData storage _self, stHolders storage _holders, address _user) internal {
        for (uint i = 0; i < _holders.dHolders.length; i++) {
            if (_holders.dHolders[i].account == _user) {
                _self.depositTotal -= _holders.dHolders[i].amount;
            }
        }
        clearDepositsQueue(_holders,_user);
    }

    ///@notice Clear out Memory for deposits
    ///@param _holders stHolders structure from main contract
    ///@param _user address of user to clear
    function clearDepositsQueue(stHolders storage _holders, address _user) internal {        
        if (_user == address(0)) {
            for (uint i = _holders.dHolders.length;i>0;i--) {
                delete _holders.dQueue[_holders.dHolders[i-1].account];
                _holders.dHolders.pop();
            }
            delete _holders.dHolders;
        }
        else {
            for(uint i = _holders.dQueue[_user].length;i>0;i--){
                delete _holders.dHolders[_holders.dQueue[_user][i-1]];
            }
            delete _holders.dQueue[_user];
        }
    }


    /// @notice Remove all withdrawals to accountholder
    /// @param _self stHolders structure from main contract
    function commitWithdrawals(stData storage _self, stHolders storage _holders) private {
        for (uint i = _holders.wHolders.length; i > 0; i--) {
            address _user = _holders.wHolders[i-1].account;
            _self.withdrawTotal -= _holders.wHolders[i-1].amount;
            _self.poolTotal -= _holders.wHolders[i-1].amount;
            
            if (_holders.iHolders[_user].amount == 0) {
                if (_holders.iQueue.length > 1) {
                    _holders.iQueue[_holders.iHolders[_user]._pos] = _holders.iQueue[_holders.iQueue.length-1];
                }

                _holders.iQueue.pop();
                delete _holders.iHolders[_user];
            }
        }
        clearWithdrawalQueue(_holders,address(0));
    }

    ///@notice Clear out withdrawal queue for sepcific user
    ///@param _self stHolders structure from main contract
    ///@param _user address of user to clear
    function clearWithdrawals(stData storage _self, stHolders storage _holders, address _user) internal {
        for (uint i = 0; i < _holders.wHolders.length; i++) {
            if (_holders.wHolders[i].account == _user) {
                _self.withdrawTotal -= _holders.wHolders[i].amount;
                if (_self.poolTotal > 0) _self.poolTotal -= _holders.wHolders[i].amount;
            }
        }
        clearWithdrawalQueue(_holders,_user);
    }

    ///@notice Clear out Memory for deposits
    ///@param _holders stHolders structure from main contract
    ///@param _user address of user to clear
    function clearWithdrawalQueue(stHolders storage _holders, address _user) internal {        
        if (_user == address(0)) {
            for (uint i = _holders.wHolders.length;i>0;i--) {
                delete _holders.wQueue[_holders.wHolders[i-1].account];
                _holders.wHolders.pop();
            }
            delete _holders.wHolders;
        }
        else {
            for(uint i = _holders.wQueue[_user].length;i>0;i--){
                delete _holders.wHolders[_holders.wQueue[_user][i-1]];
            }
            delete _holders.wQueue[_user];
        }
    }

    ///@notice Function will distribute BNB to stakeholders based on stake
    ///@return _feeAmount - amount of BNB recovered in fees
    ///@param _self stHolders structure from main contract
    ///@param _amount BNB to be distributed to stakeholders based on stake. External function will supply this.
    ///@dev emits "distContrib_evt" for each distribution to user
    ///@dev emits "distContribTotal_evt" total amount distributed
    ///@dev will revert with math error if more stake is allocated than was supplied in _amount parameter
    function distContrib(stData storage _self, stHolders storage _holders, uint _amount, address _beacon) internal returns (uint _feeAmount) {        
        if (_amount > 0) {
            uint _totalDist = 0;
            
            (uint fee,) = iBeacon(_beacon).getFee('DEFAULT','HARVEST',address(0));  // Get the fee without any discounts  

            bool check_fee;
            {// Stack control
                uint last_discount =  iBeacon(_beacon).getDataUint('LASTDISCOUNT'); // Get the timestamp of the last discount applied from the beacon
                check_fee = (last_discount >= _self.lastDiscount)?true:false;
                if (check_fee) _self.lastDiscount = last_discount;
            }
            for(uint i = 0; i < _holders.iQueue.length;i++) {
                address _user = _holders.iQueue[i];

                uint discount; 
            
                if (check_fee) {    // If there are new discounts, force a check
                    uint expires;
                    (discount, expires) = iBeacon(_beacon).getDiscount(_user);
                    if (discount > 0) {
                        _holders.iHolders[_user].discount = discount;
                        _holders.iHolders[_user].discountValidTo = expires;
                    }
                } else { // otherwise use the last discount stored in contract
                    // If discountValidTo is 0, it measns it's permanant. If amount is 0 it doesn't matter, as it won't be applied
                    discount = (_holders.iHolders[_user].discountValidTo <= block.timestamp) ? _holders.iHolders[_user].discount : 0;                
                } 
                
                uint _units = calcUnits(_self, _holders, _user);
                uint share = (_amount * _units)/1e18;

                uint feeAmount = ((share * fee)/100e18);
                if (discount>0) feeAmount = feeAmount - (feeAmount *(discount/100) / (10**18)); 

                share = share - feeAmount;
                _feeAmount += feeAmount;

                //Since user cannot call this function, and parent functions (harvest, and system_liquidate) lock to prevent re-execution,  re-enterancy is not a concern
                { // stack control
                    if (_holders.iHolders[_user].holdback > 0) {
                        uint holdback = ((share * (_holders.iHolders[_user].holdback/100))/1e18);
                        if (share >= holdback){
                            share = share - holdback;

                            payable(_user).transfer(holdback);
                            emit sendHoldback_evt(_user, holdback);
                        }
                    }
                }
                
                if (_holders.iHolders[_user].amount > 0) {
                    _holders.iHolders[_user].amount += share;
                    _totalDist += share;
                }
                else {
                    payable(_user).transfer(share);
                    emit sendFunds_evt(_user, share);
                }
                emit distContrib_evt(_user, _units, share, feeAmount);
            }
            
            _self.poolTotal += _totalDist;
            require(_amount >= _totalDist,"Distribution failed");
            emit distContribTotal_evt(_totalDist,_amount);

            _self.dust += _amount - _totalDist;
        }
        commitDeposits(_self,_holders);
        commitWithdrawals(_self,_holders);
    }

    ///@notice Function will iterate through staked holders and add up total stake and compare to what contract thinks exists
    ///@param _self stHolders structure from main contract
    ///@return Calculated total
    ///@return Contract Pool Total
    function auditHolders(stData storage _self, stHolders storage _holders) public view returns (uint,uint,uint,uint) {
        uint _total = 0;
        for(uint i = _holders.iQueue.length; i > 0;i--){
            address _user = _holders.iQueue[i-1];
            _total += _holders.iHolders[_user].amount;
        }                    
        // _self.dust += 1;

        // return (_total, _self.poolTotal + _self.depositTotal - _self.withdrawTotal,_holders.dHolders.length,_holders.wHolders.length);
        return (_total, _self.poolTotal , _self.depositTotal, _self.withdrawTotal);
    }

    ///@notice Returns user info based on pool info
    ///@param _self stHolders structure from main contract
    ///@param _user Address of user
    ///@return _amount Amount of Units held by user
    ///@return _depositDate Date of last deposit
    ///@return _units Number of units held by user

    function getUserInfo(stData storage _self, stHolders storage _holders, address _user) public view returns (uint _amount,uint _depositDate,uint _units) {
        _amount = _holders.iHolders[_user].amount;
        _depositDate = _holders.iHolders[_user].depositDate;
        _units = calcUnits(_self, _holders, _user);        
    }


    ///@notice Get last deposit date for a user
    ///@param _holders stHolders structure from main contract
    ///@param _user Address of user
    ///@return _depositDate Date of last deposit
    function getLastDepositDate(stHolders storage _holders, address _user) public view returns (uint _depositDate) {
        _depositDate = _holders.iHolders[_user].depositDate;
    }

    ///@notice Remove specified liquidity from the pool
    ///@param _units percent of total liquidity to remove
    ///@return amountTokenA of liquidity removed (Token A)
    ///@return amountTokenB of liquidity removed (Token B)
    function removeLiquidity(stData storage iData, iBeacon.sExchangeInfo memory exchangeInfo,  uint _units) external returns (uint amountTokenA, uint amountTokenB){
        (uint _lpBal,) = iMasterChef(exchangeInfo.chefContract).userInfo(iData.poolId,address(this));
        if (_units != 0) {
            _lpBal = (_units * _lpBal)/1e18;
            if(_lpBal == 0) revert sdInsufficentFunds();

        }

        uint deadline = block.timestamp + DEPOSIT_HOLD;
        iMasterChef(exchangeInfo.chefContract).withdraw(iData.poolId,_lpBal);
        
        _lpBal = ERC20(iData.lpContract).balanceOf(address(this));

        if (iData.token0 == WBNB_ADDR || iData.token1 == WBNB_ADDR) {
            (amountTokenA, amountTokenB) = iRouter(exchangeInfo.routerContract).removeLiquidityETH(iData.token0==WBNB_ADDR?iData.token1:iData.token0,_lpBal,0,0,address(this), deadline);
            (amountTokenA, amountTokenB) = iData.token0 == WBNB_ADDR ? (amountTokenB, amountTokenA) : (amountTokenA, amountTokenB); // returns eth to amountTokenB
        }
        else
            (amountTokenA, amountTokenB) = iRouter(exchangeInfo.routerContract).removeLiquidity(iData.token0,iData.token1,_lpBal,0,0,address(this), deadline);

        return (amountTokenA, amountTokenB);
    }

    //@notice helper function to add liquidity to the pool
    //@param _amount0 amount of token0 to add to the pool
    //@param _amount1 amount of token1 to add to the pool    
    function addLiquidity(stData storage iData, iBeacon.sExchangeInfo memory exchangeInfo,uint amount0, uint amount1) external {
        uint amountA;
        uint amountB;
        uint liquidity;

        if (iData.token1 == WBNB_ADDR) {
            (amountA, amountB, liquidity) = iRouter(exchangeInfo.routerContract).addLiquidityETH{value: amount1}(iData.token0, amount0, 0,0, address(this), block.timestamp);
        }
        else if (iData.token0 == WBNB_ADDR) {
            (amountA, amountB, liquidity) = iRouter(exchangeInfo.routerContract).addLiquidityETH{value: amount0}(iData.token1, amount1, 0,0, address(this), block.timestamp);
        }
        else {
            ( amountA,  amountB, liquidity) = iRouter(exchangeInfo.routerContract).addLiquidity(iData.token0, iData.token1, amount0, amount1, 0, 0, address(this), block.timestamp);
        }

        iMasterChef(exchangeInfo.chefContract).deposit(iData.poolId,liquidity);
        emit sdLiquidityProvided(amountA, amountB, liquidity);
    }


    ///@notice take amountIn for path[0] and swap for token1
    ///@param amountIn amount of path[0]
    ///@param path token path required for swap 
    ///@return resulting amount of path[1] swapped 
    function swap(iBeacon.sExchangeInfo memory exchangeInfo,uint amountIn, address[] memory path) external returns (uint){
        if(amountIn == 0) revert sdInsufficentFunds();

        uint _cBalance = address(this).balance;
        if (path[0] == WBNB_ADDR && path[path.length-1] == WBNB_ADDR) {
            if (ERC20(WBNB_ADDR).balanceOf(address(this)) >= amountIn) {
                iWBNB(WBNB_ADDR).withdraw(amountIn);
                _cBalance = address(this).balance;
            }
            if (amountIn > _cBalance) revert sdInsufficentFunds();
            return amountIn;
        }

        uint pathLength = (exchangeInfo.intermediateToken != address(0) && path[0] != exchangeInfo.intermediateToken && path[1] != exchangeInfo.intermediateToken) ? 3 : 2;
        address[] memory swapPath = new address[](pathLength);

        if (pathLength == 2) {
            swapPath[0] = path[0];
            swapPath[1] = path[1];
        }
        else {
            swapPath[0] = path[0];
            swapPath[1] = exchangeInfo.intermediateToken;
            swapPath[2] = path[1];
        }

        uint[] memory amounts;


        if (path[0] == WBNB_ADDR && ERC20(WBNB_ADDR).balanceOf(address(this)) >= amountIn) {
            iWBNB(WBNB_ADDR).withdraw(amountIn);
            _cBalance = address(this).balance;
        }
        uint deadline = block.timestamp + 600; 

        if (path[path.length - 1] == WBNB_ADDR) {
            amounts = iRouter(exchangeInfo.routerContract).swapExactTokensForETH(amountIn, 0,  swapPath, address(this), deadline);
        } else if (path[0] == WBNB_ADDR && _cBalance >= amountIn) {
            amounts = iRouter(exchangeInfo.routerContract).swapExactETHForTokens{value: amountIn}(0,swapPath,address(this),deadline);
        }
        else {
            amounts = iRouter(exchangeInfo.routerContract).swapExactTokensForTokens(amountIn, 0,swapPath,address(this),deadline);
        }
        emit Swap(path[0], path[path.length-1],amounts[0], amounts[amounts.length-1]);
        return amounts[amounts.length-1];
    }
}

//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   
uint constant MAX_INT = type(uint).max;
uint constant DEPOSIT_HOLD = 15; // 600;
address constant WBNB_ADDR = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

struct stData {
    address lpContract;
    address token0;
    address token1;

    uint poolId;
    uint dust;        
    uint poolTotal;
    uint unitsTotal;
    uint depositTotal;
    uint withdrawTotal;
    uint lastProcess;
    uint lastDiscount;
    bool paused;
}

struct sHolders {
    uint amount;
    uint holdback;
    uint depositDate;
    uint discount;
    uint discountValidTo;        
    uint _pos;
}

struct transHolders {
    uint amount;
    uint timestamp;
    address account;
}

struct stHolders{
    mapping (address=>sHolders) iHolders;
    address[] iQueue;

    transHolders[] dHolders;        
    mapping(address=>uint[]) dQueue;
    
    transHolders[] wHolders;        
    mapping(address=>uint[]) wQueue;
}

interface iMasterChef{
     function pendingCake(uint256 _pid, address _user) external view returns (uint256);
     function poolInfo(uint _poolId) external view returns (address, uint,uint,uint);
     function userInfo(uint _poolId, address _user) external view returns (uint,uint);
     function deposit(uint poolId, uint amount) external;
     function withdraw(uint poolId, uint amount) external;
     function cakePerBlock() external view returns (uint);
     function updatePool(uint poolId) external;
}

interface iMasterChefv2{
    function poolInfo(uint _poolId) external view returns (uint, uint,uint,uint,bool);
    function lpToken(uint _poolId) external view returns (address);
}


interface iRouter { 
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);    
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function addLiquidityETH(address token,uint amountTokenDesired ,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(address tokenA,address tokenB, uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
}

interface iLPToken{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);    
}

interface iBeacon {
    struct sExchangeInfo {
        address chefContract;
        address routerContract;
        address rewardToken;
        address intermediateToken;
        address baseToken;
        string pendingCall;
        string contractType_solo;
        string contractType_pooled;
        bool psV2;
    }

    function getExchangeInfo(string memory _name) external view returns(sExchangeInfo memory);
    function getFee(string memory _exchange, string memory _type, address _user) external returns(uint,uint);
    function getFee(string memory _exchange, string memory _type) external returns(uint,uint);
    function getDiscount(address _user) external view returns(uint,uint);
    function getConst(string memory _exchange, string memory _type) external returns(uint64);
    function getExchange(string memory _exchange) external view returns(address);
    function getAddress(string memory _key) external view returns(address _value);
    function getDataUint(string memory _key) external view returns(uint _value);
}

interface iWBNB {
    function withdraw(uint wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}