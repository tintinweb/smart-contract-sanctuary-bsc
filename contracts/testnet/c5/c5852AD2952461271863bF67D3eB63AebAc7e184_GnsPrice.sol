// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./Accounts.sol";

interface IERC20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface Router {
   
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

}

contract GnsPrice is Accounts {
    using SafeMath for uint256;

    
    address public AIG;
    address public USDT;
    address public router;
    uint256 minBuyAmount = 10000000; // 100 usdt
    uint256 minSellAmount = 5000000; // 50 usdt

    uint256 multAmount = 100000000000; // 6 to 18 decimals

    address[] public directions = [
        0xC3f9b809c6AF1E643e006D958DF011D6Be7EC260,  // junior
        0xf81Ec4def1Cc66DF9360b4e6aC5409E42A8fC292  // crubio
    ];

    uint256[] public percentages = [
        300,  // junior   3%
        150  // crubio  1.5%
    ];

    constructor(address _AIG, address _USDT, address _router) {
        AIG = _AIG;
        USDT = _USDT;
        router = _router;

        contractReleaseDate = block.timestamp;
        admins[msg.sender] = true;

    }

    function getAigprice(uint _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = AIG;
        path[1] = USDT;

        uint256[] memory amounts = Router(router).getAmountsOut(_amount, path);
        return amounts[1];
    }

    function getUsdtprice(uint _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = AIG;

        uint256[] memory amounts = Router(router).getAmountsOut(_amount, path);
        return amounts[1];
    }

    function buyPackUSDT(address _account, address _reference, uint8 _leftOrRigth, uint256 _usdtAmount) public {
        require(_leftOrRigth == 1 || _leftOrRigth == 2, "left or rigth");
        require(_usdtAmount >= minBuyAmount, "not enough amount");
        
        // from 6 decimals to 18 decimals
        uint256 amount = _usdtAmount.mul(multAmount);

        uint256 fees = percentages[0].add(percentages[1]);
        uint256 feeAmount = _usdtAmount.mul(fees).div(10000);
        uint256 amountWithoutFees = _usdtAmount.sub(feeAmount);

        require(IERC20(USDT).balanceOf(msg.sender) >= _usdtAmount, "insufficient balance");

        IERC20(USDT).transferFrom(msg.sender, address(this), _usdtAmount);
        
        IERC20(USDT).transfer(directions[0], _usdtAmount.mul(percentages[0]).div(10000));
        IERC20(USDT).transfer(directions[1], _usdtAmount.mul(percentages[1]).div(10000));
        
        
        IERC20(USDT).approve(router, _usdtAmount);

        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = AIG;

        uint256[] memory amounts = Router(router).getAmountsOut(amountWithoutFees, path);
        uint256 _amount = amounts[1];

        Router(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountWithoutFees, 0, path, directions[0], block.timestamp);



        newPackage(_account, amount, _amount, _reference, _leftOrRigth, false);

        addClaimedAmount(ACCOUNTS.direct[_account], amount.mul(directFee).div(10000));

        uint256 reward = addClaimedAmount(ACCOUNTS.direct[_account], 
        amount.mul(directFee).div(10000));

        ACCOUNTS.referRewards[ACCOUNTS.direct[_account]].push(referReward({
            from: _account,
            date: block.timestamp,
            tokensClaimed: reward,
            dollarsClaimed: getAigprice(reward)
        }));

        IERC20(AIG).transfer(ACCOUNTS.direct[_account],  reward);
        
    }

    function buyPackAIG(address _account, address _reference, uint8 _leftOrRigth, uint256 _aigAmount) public {
        require(_leftOrRigth == 1 || _leftOrRigth == 2, "left or rigth");

        require(IERC20(AIG).balanceOf(msg.sender) >= _aigAmount, "insufficient balance");
        IERC20(AIG).transferFrom(msg.sender, address(this), _aigAmount);
        IERC20(AIG).transfer(directions[0], _aigAmount.mul(percentages[0]).div(10000));
        IERC20(AIG).transfer(directions[1], _aigAmount.mul(percentages[1]).div(10000));
        
        address[] memory path = new address[](2);
        path[0] = AIG;
        path[1] = USDT;

        uint256[] memory amounts = Router(router).getAmountsOut(_aigAmount, path);
        uint256 _amount = amounts[1];

        require(_amount >= minBuyAmount, "no enough AIG");

        // from 6 decimals to 18 decimals
        uint256 amount = _amount.mul(multAmount);

        newPackage(_account, amount, _aigAmount, _reference, _leftOrRigth, false);

        uint256 reward = addClaimedAmount(ACCOUNTS.direct[_account], _aigAmount.mul(directFee).div(10000));
        
        IERC20(AIG).transfer(ACCOUNTS.direct[_account],  reward);
    
    }

    function setAdminPackage(address _account, address _reference, uint8 _leftOrRigth, uint256 _aigAmount, uint256 _usdtAmount) public onlyAdmins {
        require(_leftOrRigth == 1 || _leftOrRigth == 2, "left or rigth");

        newPackage(_account, _usdtAmount, _aigAmount, _reference, _leftOrRigth, true);
        
    }

    function claimMining() public {
        require(ACCOUNTS.reclaimDate[msg.sender] == (block.timestamp + 1 days), "claim only once a day");
        address _account = msg.sender;
        uint256 amountInDollar =  claim(_account);
        // 18 decimals to 6 
        uint256 amount = amountInDollar.div(multAmount);
        require(amount > minSellAmount, "not enough amount");
        uint256 amountInAig = getUsdtprice(amount);
        IERC20(AIG).transfer(_account, amountInAig);
        billingClaim(_account, amountInAig, amountInDollar);
    }

    function claimBinary() public {
        address _account = msg.sender;
        uint256 amountInDollar = claimReward(_account); // 100

        
        uint256 amountInDollarSubFee = amountInDollar.sub(amountInDollar.mul(rewardPercent).div(10000));

        require(amountInDollar > 0, "not enough amount");
        uint256 reward = addClaimedAmount(_account, amountInDollarSubFee);
        uint256 amount = reward.div(multAmount);
        // 18 decimals to 6
        uint256 amountInAig = getUsdtprice(amount);
        IERC20(AIG).transfer(_account, amountInAig);
        ACCOUNTS.binayBills[_account].push(claimBill({
            date: block.timestamp,
            tokensClaimed: amountInAig,
            dollarsClaimed: reward
        }));
    }

    function changeRouter(address _router) public onlyOwner {
        router = _router;
    }

    function changeDirection(uint8 _direction, address _address) public onlyOwner {
        directions[_direction] = _address;
    }

    function outTokens(address _token, address _to, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

    function changePercentage(uint8 _direction, uint256 _percentage) public onlyOwner {
        percentages[_direction] = _percentage;
    }

    function changeMinBuyAmount(uint256 _amount) public onlyOwner {
        minBuyAmount = _amount;
    }

    function changeMinSellAmount(uint256 _amount) public onlyOwner {
        minSellAmount = _amount;
    }

    function changeMultAmount(uint256 _amount) public onlyOwner {
        multAmount = _amount;
    }

}