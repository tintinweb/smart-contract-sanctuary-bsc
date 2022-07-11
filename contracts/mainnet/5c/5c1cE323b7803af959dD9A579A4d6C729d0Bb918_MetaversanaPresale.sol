// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

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
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);
}

contract MetaversanaPresale {
    // Contract creator
    address owner;
    // Purchase token
    IERC20 token;
    // allow only users whitelisted to interact
    bool onlyWhitelisted = true;
    // Pause and resume contract interaction
    bool paused = false;
    // whitelisted addresses
    address[] whitelistedAddresses;
    // users presale balances
    mapping(address => uint256) balances;
    // Minimum amount of purchase token
    uint256 minAmount = 500 ether;
    // Maximum amountof purchase token
    uint256 maxAmount = 50_000 ether;
    // Amount of token to sale
    uint256 initialSupply = 20_000_000;
    // Purcahsed token price ($MTVR)
    uint256 tokenPrice = 0.03 ether;
    // Contract address
    address treasury = address(this);

    // Transfer event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * @dev Modifier allow only contract owner
     *
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only seller can call this.");
        _;
    }

    function setMinAmount(uint256 x) public onlyOwner {
        minAmount = x;
    }

    function setMaxAmount(uint256 x) public onlyOwner {
        maxAmount = x;
    }

    function getMinAmount() public view returns (uint256) {
        return minAmount;
    }

    function getMaxAmount() public view returns (uint256) {
        return maxAmount;
    }

    function addSupply(uint256 x) public onlyOwner {
        balances[owner] += x;
    }

    function setSupply(uint256 x) public onlyOwner {
        balances[owner] = x;
    }

    function setPurchaseTokenAddress(address addr) public onlyOwner {
        token = IERC20(addr);
    }

    function getPurchaseTokenAddress() public view returns (IERC20) {
        return token;
    }

    /**
     * @dev Enable or disable the presale
     *
     */
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
    
    /**
     * @dev Enable or disable whitelist behavior
     *
     */
    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
    }
    
    /**
     * @dev Update whitelisted addresses
     *
     */
    function whitelistUsers(address[] calldata _users, bool _reset) public onlyOwner {
        if (_reset) {
            delete whitelistedAddresses;
            whitelistedAddresses = _users;
        } else {
            for (uint i = 0; i < _users.length; i++) {
                addWhitelistedUser(_users[i]);
            }
        }
    }

    /**
     * @dev Add new address to whitelist 
     *
     */
    function addWhitelistedUser(address _user) public onlyOwner {
        bool alreadyInWhitelist = false;
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                alreadyInWhitelist = true;
            }
        }
        if (!alreadyInWhitelist) {
            whitelistedAddresses.push(_user);
        }
    }

    function getWhitelist() public view returns(address[] memory) {
        return whitelistedAddresses;
    }

    constructor() {
        owner = msg.sender;
        balances[owner] = initialSupply;
        // BUSD: testnet 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
        // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        token = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
    }

    /**
     * @dev Store amount of token to transfer for purchased amount
     *
     */
    function sendCoin(uint256 amount) public returns (bool sufficient) {
        require(!paused, "The contract is in paused state.");
        require(balances[owner] >= 0, "No more tokens available.");
        require(amount >= minAmount, "Minimum amount is not reached.");
        require(amount <= maxAmount, "Maximum amount is reached.");
        require(isWhitelisted(msg.sender), "User is not whitelisted.");

        uint256 totalTokenToTransfer = getNbTokenToTransfer(amount);
        require(
            balances[owner] >= totalTokenToTransfer,
            "Amount is greater than available tokens."
        );
        
        require((balances[msg.sender] + totalTokenToTransfer) <= getMaximumToken() , "Maximum token per address exceeded.");
        
        uint256 busdBalance = getPurchaseTokenBalance(msg.sender);
        require(busdBalance > amount, "Insufficient funds");
        // transfers BUSD that belong to your contract to the specified address
        bool ok = token.transferFrom(msg.sender, treasury, amount);
        if (ok) {
            balances[owner] -= totalTokenToTransfer;
            balances[msg.sender] += totalTokenToTransfer;
            emit Transfer(msg.sender, owner, totalTokenToTransfer);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer all purchase token funds to owner wallet
     */
    function withdraw() public onlyOwner {
        uint256 amount = getPurchaseTokenBalance(address(this));
        token.approve(address(this), amount);
        token.transferFrom(address(this), owner, amount);
    }

    /**
     * @dev Determine if an address is whitelisted
     *
     */
    function isWhitelisted(address _user) public view returns (bool) {
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Get buyed token balance
     *
     */
    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }

    /**
     * @dev Get purchase token balance
     *
     */
    function getPurchaseTokenBalance(address addr) public view returns (uint256) {
        return token.balanceOf(addr);
    }

     /**
     * @dev Retrieve amount of token to transfer for purchased amount
     *
     */
    function getNbTokenToTransfer(uint256 amount)
        public
        view
        returns (uint256)
    {
        return ceilDiv(amount, tokenPrice);
    }

     /**
     * @dev Retrieve maximum amount of token for an address
     *
     */
    function getMaximumToken()
        public
        view
        returns (uint256)
    {
        return ceilDiv(maxAmount, tokenPrice);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
}