/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;
    
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

abstract contract Slippage {
    function slippage(uint256 amountToWei, address _address) external virtual;
}

contract HammerToken is IERC20, Ownable {

    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private buyAmount;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private lastPurchaseTime;

    mapping(address => address) private inviter;
    address public swapRouter;
    address private fundAddress;
    
    uint private fundRatio;
    uint private routerRatio;
    uint private shortestTradingTime; // second


    address private projectPartyAddress; //?????????????????????
    address private technologyAddress; //?????????????????????
    address private destroyAddress; //??????????????????
    address private ecologicalConstructionAddress; //????????????????????????
    address private teamAddress; //??????????????????
    address private bCurrencyAddress; //B?????????

    uint private projectPartyRatio; //???????????????
    uint private technologyRatio;   //????????????
    uint private destroyRatio;      //????????????
    uint private ecologicalConstructionRatio; //??????????????????
    uint private teamRatio; //????????????
    uint private bCurrencyRatio;    ////B?????????

    uint private totalPercentage; //?????????

    
    constructor() {

        _name = "Hammer";
        _symbol = "HME";
        _decimals = 18;

        _totalSupply = 26000 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;

        shortestTradingTime = 45;

        destroyAddress = 0x000000000000000000000000000000000000dEaD; //??????????????????
        projectPartyRatio = 20; //?????????????????????
        technologyRatio = 10; //??????????????????
        destroyRatio =10;//??????????????????
        ecologicalConstructionRatio = 20;//????????????????????????
        teamRatio = 20;//??????????????????
        bCurrencyRatio = 20;//??????B?????????
        totalPercentage = 1000; //?????????
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

		_transfer(sender, recipient, amount);
		
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /*??????????????????*/
    function directPurchase(address recipient,uint256 amount) public returns(bool){
        require(recipient != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        _balances[msg.sender] = _balances[msg.sender].sub(amount); //????????????????????????
        _balances[destroyAddress] = _balances[destroyAddress].add(amount); //??????????????????

        emit Transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, destroyAddress, amount);
        return true;
    }

    /*????????????*/
    function mallPurchase(address recipient, uint256 amount, uint256 let_interest_rate) public  returns(bool){
        require(recipient != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 poolAmount = amount.mul(let_interest_rate).div(100).div(2); //?????????????????????
        uint256 blackHoleAmount = amount.sub(poolAmount); //?????????????????????

        _balances[msg.sender] = _balances[msg.sender].sub(amount); //????????????????????????
        _balances[address(this)] = _balances[address(this)].add(poolAmount);//???????????????
        _balances[destroyAddress] = _balances[destroyAddress].add(blackHoleAmount); //??????????????????

        emit Transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, address(this), poolAmount);
        emit Transfer(msg.sender, destroyAddress, blackHoleAmount);
        return true;
    }

   

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function excludeFromFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = true;
    }

    function includeInFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = false;
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address _address) public view returns (bool) {
        return _isExcludedFromFee[_address];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(sender != swapRouter && recipient != swapRouter && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
        }

        if(sender == swapRouter && !_isExcludedFromFee[recipient]) {
            //??????
            lastPurchaseTime[recipient] = block.timestamp;
            //??????????????????????????????
            uint256 projectPartyAmount = amount.mul(projectPartyRatio).div(1000);//?????????
            uint256 technologyAmount = amount.mul(technologyRatio).div(1000);//?????????
            uint256 destroyAmount = amount.mul(destroyRatio).div(1000); //?????????
            uint256 ecologicalConstructionAmount = amount.mul(ecologicalConstructionRatio).div(1000); //???????????????
            uint256 teamAmount = amount.mul(teamRatio).div(1000); //??????
            uint256 bCurrencyAmount = amount.mul(bCurrencyRatio).div(1000); //B??????
            uint256 totalProportion = totalPercentage.sub(projectPartyRatio).sub(technologyRatio).sub(destroyRatio).sub(ecologicalConstructionRatio).sub(teamRatio).sub(bCurrencyRatio);
            uint256 surplus = amount.mul(totalProportion).div(1000); //??????????????????
            //????????????????????????????????????
            _balances[sender] = _balances[sender].sub(amount); //????????????????????????
            _balances[recipient] = _balances[recipient].add(surplus); //??????????????????
            _balances[projectPartyAddress] = _balances[projectPartyAddress].add(projectPartyAmount); //????????????????????? 
            _balances[technologyAddress] = _balances[technologyAddress].add(technologyAmount);//?????????????????????
            _balances[destroyAddress] = _balances[destroyAddress].add(destroyAmount); //?????????????????????
            _balances[ecologicalConstructionAddress] = _balances[ecologicalConstructionAddress].add(ecologicalConstructionAmount); //???????????????????????????
            _balances[teamAddress] = _balances[teamAddress].add(teamAmount); //??????????????????
            _balances[bCurrencyAddress] = _balances[bCurrencyAddress].add(bCurrencyAmount); //B??????????????????

            //????????????
            emit Transfer(sender, recipient, surplus);
            emit Transfer(sender, projectPartyAddress, projectPartyAmount);
            emit Transfer(sender, technologyAddress, technologyAmount);
            emit Transfer(sender, destroyAddress, destroyAmount);
            emit Transfer(sender, ecologicalConstructionAddress, ecologicalConstructionAmount);
            emit Transfer(sender, teamAddress, teamAmount);
            emit Transfer(sender, bCurrencyAddress,bCurrencyAmount);

            if(_balances[address(this)] > 0) {
                uint256 tempAmount = _balances[address(this)];
                _balances[sender] = _balances[sender].add(tempAmount);
                _balances[address(this)] = 0;
                emit Transfer(address(this), sender, tempAmount);
            }

        } else if(recipient == swapRouter && !_isExcludedFromFee[sender]) {
            //??????
            require(block.timestamp - lastPurchaseTime[sender] >= shortestTradingTime, "Frequent operation");
            //??????????????????????????????
            uint256 projectPartyAmount = amount.mul(projectPartyRatio).div(1000);//?????????
            uint256 technologyAmount = amount.mul(technologyRatio).div(1000);//?????????
            uint256 destroyAmount = amount.mul(destroyRatio).div(1000); //?????????
            uint256 ecologicalConstructionAmount = amount.mul(ecologicalConstructionRatio).div(1000); //???????????????
            uint256 teamAmount = amount.mul(teamRatio).div(1000); //??????
            uint256 bCurrencyAmount = amount.mul(bCurrencyRatio).div(1000); //B??????
            uint256 totalProportion = totalPercentage.sub(projectPartyRatio).sub(technologyRatio).sub(destroyRatio).sub(ecologicalConstructionRatio).sub(teamRatio).sub(bCurrencyRatio);
            uint256 surplus = amount.mul(totalProportion).div(1000); //??????????????????
            //????????????????????????????????????
            _balances[sender] = _balances[sender].sub(amount); //????????????????????????
            _balances[recipient] = _balances[recipient].add(surplus); //??????????????????
            _balances[projectPartyAddress] = _balances[projectPartyAddress].add(projectPartyAmount); //????????????????????? 
            _balances[technologyAddress] = _balances[technologyAddress].add(technologyAmount);//?????????????????????
            _balances[destroyAddress] = _balances[destroyAddress].add(destroyAmount); //?????????????????????
            _balances[ecologicalConstructionAddress] = _balances[ecologicalConstructionAddress].add(ecologicalConstructionAmount); //???????????????????????????
            _balances[teamAddress] = _balances[teamAddress].add(teamAmount); //??????????????????
            _balances[bCurrencyAddress] = _balances[bCurrencyAddress].add(bCurrencyAmount); //B??????????????????

            //????????????
            emit Transfer(sender, recipient, surplus);
            emit Transfer(sender, projectPartyAddress, projectPartyAmount);
            emit Transfer(sender, technologyAddress, technologyAmount);
            emit Transfer(sender, destroyAddress, destroyAmount);
            emit Transfer(sender, ecologicalConstructionAddress, ecologicalConstructionAmount);
            emit Transfer(sender, teamAddress, teamAmount);
            emit Transfer(sender, bCurrencyAddress,bCurrencyAmount);
        } else {

        _balances[sender] = _balances[sender].sub(amount); //????????????????????????
        _balances[destroyAddress] = _balances[destroyAddress].add(amount); //??????????????????

        
        emit Transfer(sender, destroyAddress, amount);

            // _balances[sender] = _balances[sender].sub(amount);
            // _balances[recipient] = _balances[recipient].add(amount);
            // emit Transfer(sender, recipient, amount);
        }
    }





    function changeRouter(address router) public onlyOwner {
        swapRouter = router;
    }

    /*???????????????????????????*/
    function setprojectPartyAddress(address _address) public onlyOwner{
        projectPartyAddress = _address;
    }

    /*?????????????????????*/
    function getprojectPartyAddress() public view returns (address) {
        return projectPartyAddress;
    }

    /*???????????????????????????*/
    function settechnologyAddress(address _address) public onlyOwner{
        technologyAddress = _address;
    }

    /*???????????????????????????*/
    function getTechnologAddress() public view returns(address){
        return technologyAddress;
    }

    /*??????????????????*/
    function setdestroyAddress(address _address) public onlyOwner{
        destroyAddress = _address;
    }

    /*??????????????????*/
    function getDestroyAddress() public view returns(address){
        return destroyAddress;
    }

    /*??????????????????????????????*/
    function setecologicalConstructionAddress(address _address) public onlyOwner{
        ecologicalConstructionAddress = _address;
    }

    /*??????????????????????????????*/
    function getSetecologicalConstructionAddress() public view returns(address){
        return ecologicalConstructionAddress;
    }

    /*??????????????????*/
    function setteamAddress(address _address) public onlyOwner{
        teamAddress = _address;
    }

    /*????????????????????????*/
    function getTeamAddress() public view returns(address){
        return teamAddress;
    }

    /*B???????????????*/
    function setbCurrencyAddress(address _address) public onlyOwner{
        bCurrencyAddress = _address;
    }

    /*B???????????????*/
    function getBCurrencyAddress() public view returns(address){
        return bCurrencyAddress;
    }

    /*?????????????????????*/
    function setprojectPartyRatio(uint256 ratio) public onlyOwner{
        projectPartyRatio = ratio;
    }

    /*???????????????????????????*/
    function getprojectPartyRatio() public view returns(uint256){
        return projectPartyRatio;
    }

    /*??????????????????*/
    function settechnologyRatio(uint256 ratio) public onlyOwner{
        technologyRatio = ratio;
    }

    /*????????????????????????*/
    function gettechnologyRatio() public view returns(uint256){
        return technologyRatio;
    }

    /*????????????*/
    function setdestroyRatio(uint256 ratio) public onlyOwner{
        destroyRatio = ratio;
    }

    /*??????????????????*/
    function getdestroyRatio() public view returns(uint256){
        return destroyRatio;
    }

    /*????????????????????????*/
    function setecologicalConstructionRatio(uint256 ratio) public onlyOwner{
        ecologicalConstructionRatio = ratio;
    }

    /*????????????????????????*/
    function getecologicalConstructionRatio() public view returns(uint256){
        return ecologicalConstructionRatio;
    }

    /*??????????????????*/
    function setteamRatio(uint256 ratio) public onlyOwner{
        teamRatio = ratio;
    }

    /*??????????????????*/
    function getteamRatio() public view returns(uint256){
        return teamRatio;
    }

    /*??????B?????????*/
    function setbCurrencyRatio(uint256 ratio) public onlyOwner{
        bCurrencyRatio = ratio;
    }

    /*??????B?????????*/
    function getbCurrencyRatio() public view returns(uint256){
        return bCurrencyRatio;
    }

 

    function setShortestTradingTime(uint _time) public onlyOwner {
        shortestTradingTime = _time;
    }

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

    function updateInviter(address _address, address inviterAddress) public onlyOwner {
        inviter[_address] = inviterAddress;
    }

}