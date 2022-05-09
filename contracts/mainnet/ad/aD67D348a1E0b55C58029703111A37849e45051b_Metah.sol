/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
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
    event Burn(address indexed from, uint256 value);
}

contract Metah is IERC20 {
    uint256 private constant eighteen_decimals_value =
        1_000_000_000_000_000_000;
    // ERC20 variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 450_000_000 * eighteen_decimals_value;

    // General variables
    string public constant name = "Mateh";
    string public constant symbol = "$MTH";
    uint8 public constant decimals = 18;
    address public _admin;
    address public _valid;
    // Utility variables
    bool public _isPaused;
    mapping(address => bool) public _isPausedAddress;
    struct Wallet{
        uint256 totalAmount; // total amount of wallet
        uint256 leftAmount; // left amount of wallet
        uint256 releaseTime; // release time to start distirbute tokens
        uint256 lastTimeOfTransfer; // last time call transfer
        uint256 dayToPay;
        bool isDaily; //  distirbute is daily
    }
    mapping(address => Wallet) private _wallets;

    constructor(uint _releaseTime) {
        require(_releaseTime > 0 , "Unable to perform daily transfer as release time is less than 0 or zero");
        _admin = msg.sender;
        _balances[address(this)] = _totalSupply;
        _initialTransfer(_releaseTime);
    }

    function _initialTransfer(uint _releaseTime) private {
        _transfer(
            address(this),
            0x317f05a56D7DD067760214f3eB673D91b5103e11,
            22_500_000 * eighteen_decimals_value
        ); // Marketing
        _transfer(
            address(this),
            0x317f05a56D7DD067760214f3eB673D91b5103e11,
            18_000_000 * eighteen_decimals_value
        ); // CEX
        _transfer(
            address(this),
            0x317f05a56D7DD067760214f3eB673D91b5103e11,
            4_500_000 * eighteen_decimals_value
        ); // Liquidity
        _wallets[0x317f05a56D7DD067760214f3eB673D91b5103e11] 
            =  Wallet(
                36_500_000 * eighteen_decimals_value,
                36_500_000 * eighteen_decimals_value,
                _releaseTime,
                _releaseTime,
                365,
                true

        );//Jogging Mode
        _wallets[0x0bfC6cEC9B26378699d08133C1d0c47178a186FD] 
            =  Wallet(
                76_000_000 * eighteen_decimals_value,
                76_000_000 * eighteen_decimals_value,
                _releaseTime,
                _releaseTime,
                365,
                true

        );//Racing Mode
        _wallets[0x0bfC6cEC9B26378699d08133C1d0c47178a186FD] 
            =  Wallet(
                63_000_000  * eighteen_decimals_value,
                63_000_000 * eighteen_decimals_value,
                _releaseTime,
                _releaseTime,
                365,
                true

        );//Staking
        _wallets[0x317f05a56D7DD067760214f3eB673D91b5103e11] 
            =  Wallet(
                45_000_000  * eighteen_decimals_value,
                45_000_000 * eighteen_decimals_value,
                _releaseTime + 31556926,
                _releaseTime + 31556926,
                730,
                false

        );//Team Tokens
        _wallets[0x86150792E56A9D4805049a0b171f9d8EaD10793A] 
            =  Wallet(
                112_500_000  * eighteen_decimals_value,
                112_500_000 * eighteen_decimals_value,
                _releaseTime,
                _releaseTime,
                365,
                true

        );//Governance Pool
        _wallets[0x4e04C3085aB13f74Ab2a84A07fE6aA8b9294d3B8] 
            =  Wallet(
                45_000_000  * eighteen_decimals_value,
                45_000_000 * eighteen_decimals_value,
                _releaseTime + 7889229,
                _releaseTime + 7889229,
                305,
                false

        );//Private Sales
        _wallets[0x876345Ffdcafb1B346F3d91D028081dC2F16C17b] 
            =  Wallet(
                22_500_000  * eighteen_decimals_value,
                22_500_000 * eighteen_decimals_value,
                _releaseTime + 7889229,
                _releaseTime + 7889229,
                365,
                false

        );//NFT Sales
        _wallets[0x876345Ffdcafb1B346F3d91D028081dC2F16C17b] 
            =  Wallet(
                4_500_000  * eighteen_decimals_value,
                4_500_000 * eighteen_decimals_value,
                _releaseTime,
                _releaseTime,
                365,
                false

        );//Public Sales
        
    }

    /**
     * Modifiers
     */
    modifier onlyAdmin() {
        // Is Admin?
        require(_admin == msg.sender);
        _;
    }

    modifier whenPaused() {
        // Is pause?
        require(_isPaused, "Pausable: not paused Erc20");
        _;
    }

    modifier whenNotPaused() {
        // Is not pause?
        require(!_isPaused, "Pausable: paused Erc20");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        _admin = admin;
    }

    /**
     * ERC20 functions
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
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
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] - subtractedValue
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(!_isPaused, "ERC20Pausable: token transfer while paused");
        require(
            !_isPausedAddress[sender],
            "ERC20Pausable: token transfer while paused on address"
        );
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            recipient != address(this),
            "ERC20: transfer to the token contract address"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
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

    function pause() external onlyAdmin whenNotPaused {
        _isPaused = true;
    }

    function unpause() external onlyAdmin whenPaused {
        _isPaused = false;
    }

    function pausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = true;
    }

    function unPausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = false;
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public onlyAdmin returns (bool success) {
        require(_balances[address(this)] >= _value);
        _balances[address(this)] -= _value;
        _totalSupply -= _value;
        emit Burn(address(this), _value);
        return true;
    }

    /**
     * Destroy tokens ( wallet )
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burnWallet(uint256 _value) public returns (bool success) {
        require(_balances[msg.sender] >= _value);
        _balances[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    receive() external payable {
        revert();
    }

    function dailyOrWeeklyTransfer(address walletAddress) external returns(bool){
        Wallet storage wallet = _wallets[walletAddress];
        uint nowTime = block.timestamp;
        require(nowTime > wallet.releaseTime, "Unable to perform daily transfer as current time is less than date release");
        require(nowTime > wallet.lastTimeOfTransfer, "Unable to perform daily transfer as current time is less than date last transfer");
        require(wallet.dayToPay > 0, "Unable to perform daily transfer as day to pay is less than zero");
        require(wallet.leftAmount > 0, "Unable to perform daily transfer as left of amount is less than zero");
        uint dailyAmount = wallet.leftAmount / wallet.dayToPay;
        uint unpaidDays = (nowTime - wallet.lastTimeOfTransfer) / 86400 + 1;
        if(wallet.isDaily){
            wallet.lastTimeOfTransfer = nowTime + 86400; // daily
        }else {
            wallet.lastTimeOfTransfer = nowTime + 604800; // weekly
        }
        
        if(unpaidDays > wallet.dayToPay) 
            unpaidDays = wallet.dayToPay;
        wallet.dayToPay -= unpaidDays;    
        uint amount = dailyAmount * unpaidDays;   
        if(amount > wallet.leftAmount || wallet.dayToPay == 0)
            amount = wallet.leftAmount;
        wallet.leftAmount -= amount;     
        _transfer(address(this), walletAddress, amount);
        return true;
    }


}