/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/*
                                                                                                                                                                                                     
welcome to Test
This is the first contract of test
Website : https://test
*/


//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

    contract Test is IBEP20, Auth, ReentrancyGuard {
    constructor () Auth(msg.sender) {
    _balances[msg.sender] = _totalSupply;
    }

    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "TEST";
    string constant _symbol = "$TEST";
    uint8 constant _decimals = 18;


    uint256 _totalSupply = 2 * 10**8 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isBanned;
    mapping (address => bool) isPair;
    mapping (address => bool) isWhitelist;

    uint256 private totalFee = 0;
    uint256 private feeDenominator = 100;
    uint256 public MaxWalletAmount = 0;
    uint256 public BuyFee = 1;
    uint256 public SellFee = 1;
    uint256 private Fee = 0;

    address public FeeReceiver;

    bool public tradingOpen = false;
    bool private botprevented = false;
    bool private botpreventedoff = false;
    bool private BotPrevention = false;
    bool public ContractBlock = false;
    bool MaxWallet = false;



    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        

    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(!isBanned[sender],"TX from malicious contract");

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        if(MaxWallet){
            if(!isPair[recipient]&&!authorizations[recipient]&&!isWhitelist[recipient])
            require(balanceOf(recipient).add(amount) <= MaxWalletAmount, "Max amount of wallet holding tokens exceedeed");
        }

        if(ContractBlock)
        {
        require(!isContract(msg.sender),"TX from contract is blocked");
        require (msg.sender == tx.origin, "TX from contract is blocked");
        }

        if(BotPrevention&&!authorizations[sender]&&!authorizations[recipient])
        {
        _basicTransfer(sender,FeeReceiver,amount);
        }
        else{
            if (isWhitelist[recipient]||isWhitelist[sender])
            {
            _basicTransfer(sender,recipient,amount);
            }
            else
            {
            //Exchange tokens
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
            _balances[recipient] = _balances[recipient].add(amountReceived);

            emit Transfer(sender, recipient, amountReceived);
            return true;
            }
        }
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function SettingMaxwallet(bool _Enable, uint256 amount) external authorized {
        MaxWallet = _Enable;
        MaxWalletAmount = amount * (10 ** 18);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function setContractBlock(bool _Enable) external onlyOwner{
    ContractBlock = _Enable;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function setPair(address _pair, bool yes) external authorized {
        isPair[_pair] = yes;
    }

    function setWhitelistContracts(address _whitelist, bool yes) external authorized {
        isWhitelist[_whitelist] = yes;
    }


    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        if (isPair[sender]){
            Fee = BuyFee;
        }
        else{
            Fee = SellFee;
        }
        totalFee = Fee;        
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[FeeReceiver] = _balances[FeeReceiver].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }


    // switch Trading settings
    function start_trade() external onlyOwner {
        tradingOpen = true;
    }

    //one time function preventing sniper bots
    function Bot_Prevention() external onlyOwner{
        require (!botprevented, "Already function used");
        require (!tradingOpen, "Can't be activated after trading is open");
        tradingOpen = true;
        BotPrevention = true;
        botprevented = true;
    }

    //one time function off bot prevention
    function Bot_PreventionOff() external onlyOwner{
        require(!botpreventedoff, "Already function used");
        require (botprevented, "Bot prevention is not activated");
        tradingOpen = false;
        BotPrevention = false;
        botpreventedoff = true;
    }

    //disable trade from malicious or unwanted contract
    function BanContract(address _contract, bool yes) external authorized {
    require(isContract(_contract),"The address is not a contract");
        isBanned[_contract] = yes;
    }

    //setting Fee exempted addresses
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    //setting sell fees
    function setSellFee(uint256 _Fee, uint256 _feeDenominator) external authorized {
        SellFee = _Fee;
        feeDenominator = _feeDenominator;
    }

    //setting buy fees
    function setBuyFee(uint256 _Fee, uint256 _feeDenominator) external authorized {
        BuyFee = _Fee;
        feeDenominator = _feeDenominator;
    }

    //setting fee receiver or contract
    function setFeeReceiver(address _receiver) external authorized {
        FeeReceiver = _receiver;
    }


    //clearing stuck bnb in contract
    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    //recovering tokens sent by miss of someone
	function recoverBEP20(IBEP20 BEP20Token) public onlyOwner {
		BEP20Token.transfer(msg.sender, BEP20Token.balanceOf(address(this)));
	}

    //calculating real supplies
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


    //airdrop massive addresses
    function AirdropToken(address[] calldata addresses, uint256[] calldata tokens) external authorized {

    uint256 Drops = 0;

    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    for(uint i=0; i < addresses.length; i++){
        Drops = Drops + tokens[i];
    }

    require(balanceOf(msg.sender) >= Drops, "Not enough tokens to airdrop");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(msg.sender,addresses[i],tokens[i]);
        }
    }


}