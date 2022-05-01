/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

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

    function sqrrt(uint256 a) internal pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    // TODO comment actual hash value.
    bytes32 private constant ERC20TOKEN_ERC1820_INTERFACE_ID =
    keccak256("ERC20Token");

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
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
    ) public virtual override returns (bool) {
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account_, uint256 ammount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(this), account_, ammount_);
        _totalSupply = _totalSupply.add(ammount_);
        _balances[account_] = _balances[account_].add(ammount_);
        emit Transfer(address(this), account_, ammount_);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

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

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {}
}


interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function renounceManagement() public virtual override onlyOwner {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, 'Ownable: must be new owner to pull');
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableMulti {
    mapping(address => bool) private _owners;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owners[msg.sender] = true;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function isOwner(address _address) public view virtual returns (bool) {
        return _owners[_address];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owners[msg.sender], "Ownable: caller is not an owner");
        _;
    }

    function addOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        _owners[_newOwner] = true;
    }
}


contract NRT is OwnableMulti {
    uint256 private _issuedSupply;
    uint256 private _outstandingSupply;
    uint256 private _decimals;
    string private _symbol;

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    event Issued(address account, uint256 amount);
    event Redeemed(address account, uint256 amount);

    constructor(string memory __symbol, uint256 __decimals) {
        _symbol = __symbol;
        _decimals = __decimals;
        _issuedSupply = 0;
        _outstandingSupply = 0;
    }

    function issue(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "zero address");

        _issuedSupply = _issuedSupply.add(amount);
        _outstandingSupply = _outstandingSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        emit Issued(account, amount);
    }

    function redeem(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "zero address");
        require(_balances[account] >= amount, "Insufficent balance");

        _balances[account] = _balances[account].sub(amount);
        _outstandingSupply = _outstandingSupply.sub(amount);

        emit Redeemed(account, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function issuedSupply() public view returns (uint256) {
        return _issuedSupply;
    }

    function outstandingSupply() public view returns (uint256) {
        return _outstandingSupply;
    }
}

contract RavenSale is Ownable {

    address public investToken;
    address public treasury; 
    address public launchToken;

    NRT public nrt; 

    uint256 public totalraised;

    uint256 public startTime;
    
    bool public saleEnabled = true;
    bool public VCSaleEnabled = true;

    bool public whitelistSale = true;
    bool public redeemEnabled = false;

    uint256 constant stableDecimals = 18; 
    uint256 constant one = 1 ether; 
    uint256 public mininvest = 1 * 10 ** stableDecimals; 

    uint256 public maxinvestPrivate = 4000 * 10 ** stableDecimals;
    uint256 public maxinvestCapPrivate = 506250 * 10 ** stableDecimals; 
    uint256 public investedCapPrivate = 0;
    
    uint256 public maxinvestCapPublic = 500000 * 10 ** stableDecimals; 
    uint256 public investedCapPublic = 0;

    uint256 public maxinvestCapVC = 450000 * 10 ** stableDecimals;
    uint256 public investedCapVC = 0;

    uint256 public numWhitelisted = 0;
    uint256 public numInvested = 0;

    uint256 public totalredeem;
    uint256 public totalissued;
                             
    uint256 public vcPrice = 250000000000000000;
    uint256 public whitelistPrice = 222222222222222222;
    uint256 public publicPrice = 200000000000000000;

    event Invest(address investor, uint256 amount);

    mapping(address => bool) public whitelisted;
    mapping(address => bool) public vcWhitelisted;

    struct InvestorInfo {
        uint256 amountInvested; 
        uint256 vcInvested;
        uint256 privateInvested;
        uint256 publicInvested;
        bool claimed; 
    }

    mapping(address => InvestorInfo) public investorInfoMap;

    constructor() {
        investToken = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // AVAX: 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E FTM: 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75 BSC: 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        treasury = 0xc4F7E517fE58E78Fdf510994029411cE051b3488; 
        nrt = new NRT("NRT", 18); 
        startTime = 1651424400; 
    }

    function addWhitelist(address _address) external onlyOwner {
        if(!whitelisted[_address])
            numWhitelisted+=1;
        whitelisted[_address] = true;
    }

    function addMultipleWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            if(!whitelisted[_addresses[i]])
                numWhitelisted+=1;
            whitelisted[_addresses[i]] = true;
        }
    }

    function removeWhitelist(address _address) external onlyOwner {
        whitelisted[_address] = false;
    }

    function addVCWhitelist(address _address) external onlyOwner {
        if(!vcWhitelisted[_address])
            numWhitelisted+=1;
        vcWhitelisted[_address] = true;
    }

    function addMultipleVCWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            if(!vcWhitelisted[_addresses[i]])
                numWhitelisted+=1;
            vcWhitelisted[_addresses[i]] = true;
        }
    }

    function removeVCWhitelist(address _address) external onlyOwner {
        vcWhitelisted[_address] = false;
    }


    function invest(uint256 investAmount) public {
        require(block.timestamp >= startTime, "not started yet");
        require(saleEnabled, "not enabled yet"); 
        require(investAmount >= mininvest, "Below min investment");

        InvestorInfo storage investor = investorInfoMap[msg.sender];

        if (whitelistSale) {
            require(investor.privateInvested + investAmount <= maxinvestPrivate, "above single cap - whitelist");
            require(investAmount + investedCapPrivate <= maxinvestCapPrivate, "above all cap - whitelist");
            require(whitelisted[msg.sender] == true, 'not whitelisted');
        } else {
            require(investAmount + investedCapPublic <= maxinvestCapPublic, "above all cap - public");
        }       

        require(
            ERC20(investToken).transferFrom(
                msg.sender,
                address(this),
                investAmount
            ),
            "transfer failed"
        );

        uint256 _issueAmount = 0;

        if (whitelistSale) {
            _issueAmount = (investAmount * whitelistPrice) / one;
            investor.privateInvested += investAmount;
            investedCapPrivate += investAmount;
        } else {
            _issueAmount = (investAmount * publicPrice) / one;
            investor.publicInvested += investAmount;
            investedCapPublic += investAmount;
        }
        
        nrt.issue(msg.sender, _issueAmount);
        totalissued += _issueAmount;
        totalraised += investAmount;
        

        if (investor.amountInvested == 0){
            numInvested += 1;
        }

        
        investor.amountInvested += investAmount;
        
        emit Invest(msg.sender, investAmount);
    }

    function VCInvest(uint256 investAmount) public {       
        require(VCSaleEnabled, "not enabled yet");     
        require(vcWhitelisted[msg.sender] == true, 'not whitelisted - vc');
        require(investAmount + investedCapVC <= maxinvestCapVC, "above all cap - vc");

        InvestorInfo storage investor = investorInfoMap[msg.sender];

        require(
            ERC20(investToken).transferFrom(
                msg.sender,
                address(this),
                investAmount
            ),
            "transfer failed"
        );

        uint256 _issueAmount = (investAmount * vcPrice) / one;
       
        nrt.issue(msg.sender, _issueAmount);
        totalissued += _issueAmount;

        totalraised += investAmount;
        investedCapVC += investAmount;

        if (investor.amountInvested == 0){
            numInvested += 1;
        }

        investor.amountInvested += investAmount;
        investor.vcInvested += investAmount;

        emit Invest(msg.sender, investAmount);
    }

    function redeem() public {
        require(redeemEnabled, "redeem not enabled");
        uint256 redeemAmount = nrt.balanceOf(msg.sender);
        require(redeemAmount > 0, "no amount issued");
        InvestorInfo storage investor = investorInfoMap[msg.sender];
        require(!investor.claimed, "already claimed");

        nrt.redeem(msg.sender, redeemAmount);

        totalredeem += redeemAmount;       

        require(
            ERC20(launchToken).transfer(
                msg.sender,
                redeemAmount
            ),
            "transfer failed"
        );

        investor.claimed = true;

    }

    function setTimes(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    function toggleWhitelistSale() public onlyOwner {
        whitelistSale = !whitelistSale;
    }

    function toggleVCSale() public onlyOwner {
        VCSaleEnabled = !VCSaleEnabled;
    }

    function toggleSale() public onlyOwner {
        saleEnabled = !saleEnabled;
    }

    function setMaxInvestPrivate(uint256 _maxinvestPrivate) public onlyOwner {
        maxinvestPrivate = _maxinvestPrivate;
    }

    function setMaxinvestCapPrivate(uint256 _maxinvestCapPrivate) public onlyOwner {
        maxinvestCapPrivate = _maxinvestCapPrivate;
    }

    function setMaxinvestCapPublic(uint256 _maxinvestCapPublic) public onlyOwner {
        maxinvestCapPublic = _maxinvestCapPublic;
    }

    function setMaxinvestCapVC(uint256 _maxinvestCapVC) public onlyOwner {
        maxinvestCapVC = _maxinvestCapVC;
    }

    function setLaunchToken(address _launchToken) public onlyOwner {
        launchToken = _launchToken;
    }

    function depositLaunchtoken(uint256 amount) public onlyOwner {
        require(
            ERC20(launchToken).transferFrom(msg.sender, address(this), amount),
            "transfer failed"
        );
    }

    function withdrawLaunchtoken(uint256 amount) public onlyOwner {
        require(
            ERC20(launchToken).transfer(msg.sender, amount),
            "transfer failed"
        );
    }

    function withdrawUnsupported(address _token, uint256 amount) public onlyOwner {
        require(_token != investToken, "Can not withdraw invest token.");
        require(
            ERC20(_token).transfer(msg.sender, amount),
            "transfer failed"
        );
    }

    function withdrawTreasury(uint256 amount) public onlyOwner {
        require(
            ERC20(investToken).transfer(treasury, amount),
            "transfer failed"
        );
    }

    function withdrawTreasuryByTreasury(uint256 amount) public {
        require(msg.sender == treasury, "Can Only Be Run by treasury");
        require(
            ERC20(investToken).transfer(treasury, amount),
            "transfer failed"
        );
    }

    function setWithdrawAddress(address payable _addr) public onlyOwner {
        treasury = _addr;
    }

    function enableRedeem() public onlyOwner {
        require(launchToken != address(0), "launch token not set");
        redeemEnabled = !redeemEnabled;
    }

}