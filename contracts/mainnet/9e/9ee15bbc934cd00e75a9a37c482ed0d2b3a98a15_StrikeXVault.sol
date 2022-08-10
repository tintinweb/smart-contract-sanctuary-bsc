// SPDX-License-Identifier: MIT
import "Ext.sol";

pragma solidity ^0.8.4;
contract StrikeXVault is BEP20, StrikeXVaultUsers, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    uint256 constant DEFAULT_STRATEGIST_TAX = 25; // 0.25%
    uint256 constant MAX_STRATEGIST_TAX = 50; //0.5%
    uint256 constant STRATEGIST_TAX_DIVISOR = 10000;

    uint256 constant DUST_BNB_THRESHOLD = 1e16; //0.01 BNB
    uint256 constant DUST_STRIKE_THRESHOLD = 1e20; //100 STRX
    uint256 constant MASTERCHEF_CONTRACT_ID = 1;
    uint256 constant MIN_BNB_BALANCE = 0;//1 * 10**17; // 0.1 BNB
    uint256 constant STRIKE_SWAP_PERCENTAGE = 53; //55%
    
    uint256 strategistTax = 0; // 10%
    address strategist = owner();

    IBEP20 private strike;
    IStrikeXMasterChefV2 private masterChef;
    IUniswapV2Router02 private uniswapV2Router; // pancakeswap v2 router
    IUniswapV2Pair private lpPair;
    
    
    
    event Deposit(address indexed from, uint value);
    event Withdraw(address indexed to, uint value);
    event Farm(address indexed caller, uint lpValue);
    event TaxChanged(address indexed caller, uint tax);
    
    constructor(string memory name_, string memory symbol_, address strike_, address masterChef_, address uniswapV2Router_, address strategist_) 
    BEP20(name_, symbol_)
    {
        strike = IBEP20(strike_);
        masterChef = IStrikeXMasterChefV2(masterChef_);
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        lpPair = IUniswapV2Pair(address(_getPoolInfo(MASTERCHEF_CONTRACT_ID).lpToken));
        strategist = strategist_;

        setStrategistTax(DEFAULT_STRATEGIST_TAX);
    }
    receive() external payable {}
    //WRITE
    function farm() external nonReentrant  {
        _farm();
    }
    function validateContractIntegrity() external view returns(bool){
       return _getContractInfo(MASTERCHEF_CONTRACT_ID).amount.add(lpPair.balanceOf(address(this))) == totalSupply();
    }
    /**
     * @dev Returns whether the redeemed tokens would be enough (above min threshold) to call farm.
     */
    function canFarm() public view returns(bool) {
       return redeemableTokens() > DUST_STRIKE_THRESHOLD;
    }
    /**
     * @dev Returns how much STRX tokens can be redeemed from the masterchef contract.
     */
    function redeemableTokens() public view returns (uint256) {
        return masterChef.pendingStrike(MASTERCHEF_CONTRACT_ID, address(this)); 
    }
    /**
     * @dev Deposit LP tokens to MasterChef for StrikeX allocation.
     */
    function deposit(uint256 _amount) external nonReentrant {
        _deposit(_msgSender(), _amount);
    }
    /**
     * @dev Deposit all LP tokens to MasterChef for StrikeX allocation.
     */
    function depositAll() external nonReentrant
    {
        IStrikeXMasterChefV2.PoolInfo memory pool = _getPoolInfo(MASTERCHEF_CONTRACT_ID);
        _deposit(_msgSender(), pool.lpToken.balanceOf(_msgSender()));
    }
    
    function _deposit(address _from, uint256 _amount) private {
        require(_amount > 0, "Amount too low");
        IStrikeXMasterChefV2.PoolInfo memory pool = _getPoolInfo(MASTERCHEF_CONTRACT_ID);
        require(pool.lpToken.balanceOf(_from) >= _amount, "Insufficient funds");
        _farm(); //Farm before the user LP are transferred to not instantly redeem this user
        pool.lpToken.transferFrom(address(_from), address(this), _amount);
        _depositToMasterChef(_amount);
        _addToBalance(_from, _amount);
        emit Deposit(_from, _amount);
    }
    function withdraw(uint256 _amount) external nonReentrant {
        _withdraw(_msgSender(), _amount);
    }
    
    function withdrawAll() external nonReentrant {
        _withdraw(_msgSender(), balanceOf(_msgSender()));
    }
    function _withdraw(address _to, uint256 _amount) private  {
        if(_to == address(0x0))
            return;
        _farm();
        _subFromBalance(_to, _amount);
        IStrikeXMasterChefV2.PoolInfo memory pool = _getPoolInfo(MASTERCHEF_CONTRACT_ID);
        //If the vault itself holds not enough LP token, the vault will transfer the needed amount from the Masterchef contract
        if(pool.lpToken.balanceOf(address(this)) < _amount)
            masterChef.withdraw(MASTERCHEF_CONTRACT_ID, _amount.sub(pool.lpToken.balanceOf(address(this))));

        pool.lpToken.transfer(_to, _amount);
        emit Withdraw(_to, _amount);
    }
    
    function contractBalanceSend(uint256 amount, address payable _destAddr) external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance >= amount)
        {
          _destAddr.transfer(amount);
        }
        else
        {
             _destAddr.transfer(contractETHBalance);
        }
    }
    function setStrategistTax(uint256 _tax) public onlyOwner {
        require(_tax <= MAX_STRATEGIST_TAX, "Tax too high"); //Tax can not exceed 20%
        strategistTax = _tax;
        emit TaxChanged(_msgSender(), _tax);
    }
    function emergencyWithdraw() onlyOwner external {
        uint stakedLP = _getContractInfo(MASTERCHEF_CONTRACT_ID).amount;
        masterChef.withdraw(MASTERCHEF_CONTRACT_ID, stakedLP);
        stakedLP = lpPair.balanceOf(address(this));
        uint totalWithdrawedTokens = 0;
        for(uint i = 0; i < users.length;i++)
        {
            if(users[i] == address(0))
                continue;
            if(users[i] == owner()) //Owner will get all remaining tokens at the end
                continue;
            uint256 userBalance = balanceOf(users[i]);
            if(userBalance > 0)
            {
                 //If the contract holds less LP tokens than the user should get, the user get all remaining tokens (should not happen)
                if(userBalance > stakedLP.sub(totalWithdrawedTokens))
                    userBalance = stakedLP.sub(totalWithdrawedTokens);
                totalWithdrawedTokens = totalWithdrawedTokens.add(userBalance);
                _withdraw(users[i], userBalance);
            }
            _setBalance(users[i], 0);
            _removeAddress(users[i]);
            if(totalWithdrawedTokens == stakedLP)
                break;
        }
        if(lpPair.balanceOf(address(this)) > 0)
        {
            _setBalance(owner(), 0);
            lpPair.transfer(owner(), lpPair.balanceOf(address(this)));
        }
        if(strike.balanceOf(address(this)) > 0)
           strike.transfer(owner(), strike.balanceOf(address(this)));
        if(address(this).balance > 0)
            payable(owner()).transfer(address(this).balance);
    }

    function transferAll(address to) external nonReentrant {
        transfer(to, balanceOf(_msgSender()));
    }

    //PRIVATE
    function _farm() private {
        //If the redeemable tokens not exceeding the min threshold, farming will be skipped
        if(canFarm() == false)
            return;
        uint256 lpBalanceBefore = lpPair.balanceOf(address(this));
        _swapToLPTokens();
        uint256 lpBalanceAfter = lpPair.balanceOf(address(this));
        require(lpBalanceBefore <= lpBalanceAfter, "Farm: E1");
        if(lpBalanceAfter > lpBalanceBefore)
        {
            uint256 amount = _getContractInfo(MASTERCHEF_CONTRACT_ID).amount;
            _redeemUsers(amount.add(lpBalanceBefore), amount.add(lpBalanceAfter), strategistTax);
            if(lpBalanceAfter > 0)
                _depositToMasterChef(lpBalanceAfter);

            //_sendDustToOwner();
            emit Farm(_msgSender(), lpBalanceAfter.sub(lpBalanceBefore));
        }
    }
    function _swapToLPTokens() private {
        masterChef.withdraw(MASTERCHEF_CONTRACT_ID, 0);
        if(address(_getPoolInfo(MASTERCHEF_CONTRACT_ID).lpToken) == address(strike))
            return;
        uint256 strikexBalance = strike.balanceOf(address(this));

        _swapTokensForEth(strikexBalance.mul(STRIKE_SWAP_PERCENTAGE).div(100));
        strikexBalance = strike.balanceOf(address(this));
        uint256 bnbBalance = address(this).balance - MIN_BNB_BALANCE;
        (uint reserveA, uint reserveB,) = _pairInfo(address(strike));
        uint256 neededBnb = reserveB.mul(strikexBalance).div(reserveA);

        if(neededBnb <= bnbBalance)
        {
            _addLiquidity(neededBnb, strikexBalance);
        }
        else
        {
            uint256 neededStrike = reserveA.mul(bnbBalance).div(reserveB);
            _addLiquidity(bnbBalance, neededStrike);
        }
    }
    function _sendDustToOwner() private {
        if(strike.balanceOf(address(this)) >= DUST_STRIKE_THRESHOLD)
            strike.transfer(owner(), strike.balanceOf(address(this)));
        if(address(this).balance >= DUST_BNB_THRESHOLD.add(MIN_BNB_BALANCE))
            payable(owner()).transfer(address(this).balance.sub(MIN_BNB_BALANCE));
    }
    function _depositToMasterChef(uint256 amount) private {
        lpPair.approve(address(masterChef), amount);
        masterChef.deposit(MASTERCHEF_CONTRACT_ID, amount);
    }
    function _redeemUsers(uint256 lpBalanceBefore, uint256 lpBalanceAfter, uint256 tax) private {
        if(users.length == 0)
            return;
        require(lpBalanceBefore > 0, "RU: Wrong balance");
        uint256 totalCreditedLP = 0;
        uint256 lpTax = lpBalanceAfter.sub(lpBalanceBefore).mul(tax).div(STRATEGIST_TAX_DIVISOR);
        uint256 lpBalanceAfterSubTax = lpBalanceAfter.sub(lpTax);

        for(uint i = 0; i < users.length;i++)
        {
            if(users[i] == address(0))
                continue;
            if(users[i] == strategist) //The strategist get the remaining amount
                continue;
            uint256 newBalance = balanceOf(users[i]).mul(lpBalanceAfterSubTax).div(lpBalanceBefore);
            _setBalance(users[i], newBalance);
            totalCreditedLP = totalCreditedLP.add(newBalance);
        }
        require(lpBalanceAfter >= totalCreditedLP, "RU: Error");
        //Taxes are all LP Token which were not distributed to users
        _addToBalance(strategist, lpBalanceAfter.sub(totalCreditedLP));
    }
    uint256 _toBalanceBefore =0;
    uint256 _fromBalanceBefore =0;
    function _beforeTokenTransfer(address from,  address to, uint256) override internal  {
        if(to != address(0x0))
            _toBalanceBefore = balanceOf(to);
        if(from != address(0x0))
            _fromBalanceBefore = balanceOf(from);
    }
    function _afterTokenTransfer(address from,  address to, uint256) override internal  {
        _trackHolder(from, _fromBalanceBefore);
        _trackHolder(to, _toBalanceBefore);
        _fromBalanceBefore = 0;
        _toBalanceBefore = 0;
    }
    function _trackHolder(address addr, uint balanceBefore) private
    {
        if(addr == address(0x0))
            return;
        if(balanceOf(addr) > 0 && balanceBefore == 0)
            _addAddress(addr);
        else if(balanceOf(addr) == 0)
            _removeAddress(addr);
    }
    function _setBalance(address addr, uint amount) private
    {
        if(addr == address(0x0))
            return;
        if(balanceOf(addr) == amount)
            return;
        if(balanceOf(addr) > amount)
            _burn(addr, balanceOf(addr).sub(amount));
        else
            _mint(addr, amount.sub(balanceOf(addr)));
    }
    function _addToBalance(address addr, uint amount) private
    {
        _setBalance(addr, balanceOf(addr).add(amount));
    }
    function _subFromBalance(address addr, uint amount) private
    {
        _setBalance(addr, balanceOf(addr).sub(amount));
    }
    function _pairInfo(address tokenA) private view returns (uint reserveA, uint reserveB, uint totalSupply_) {
        totalSupply_ = lpPair.totalSupply();
        (uint reserves0, uint reserves1,) = lpPair.getReserves();
        (reserveA, reserveB) = tokenA == lpPair.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
    }
    function _addLiquidity(address receiver, uint256 ethAmount, uint256 tokenAmount) private returns (uint amountToken, uint amountETH, uint liquidity) {
        strike.approve(address(uniswapV2Router), tokenAmount);
        // add the liquidity
       return uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(strike),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            receiver,
            block.timestamp + 360
        );
    }
    function _addLiquidity(uint256 ethAmount,uint256 tokenAmount) private returns (uint amountToken, uint amountETH, uint liquidity) {
        return _addLiquidity(address(this), ethAmount, tokenAmount);
    }
    /**
    * @dev Swap tokens from strike to bnb
   */
    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(strike);
        path[1] = uniswapV2Router.WETH();
        strike.approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    
    function _getPoolInfo(uint256 pid) private view  returns (IStrikeXMasterChefV2.PoolInfo memory pool) {
        return masterChef.poolInfo(pid);
    }
    function _getUserInfo(uint256 pid, address user) private view returns (IStrikeXMasterChefV2.UserInfo memory pool) {
        return masterChef.userInfo(pid, user);
    }
    function _getContractInfo(uint256 pid) private view returns (IStrikeXMasterChefV2.UserInfo memory pool) {
        return _getUserInfo(pid, address(this));
    }
}