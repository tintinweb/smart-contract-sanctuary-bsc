/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor() {
        _transferOwnership(_msgSender());
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
  
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LGEWhitelisted is Ownable {
    
    struct WhitelistRound {
        uint256 duration;
        uint256 amountMax;
        mapping(address => bool) addresses;
        mapping(address => uint256) purchased;
    }

    WhitelistRound[] public _lgeWhitelistRounds;

    uint256 public _lgeTimestamp;
    address public _lgePairAddress;

    address public _whitelister;

    event WhitelisterTransferred(address indexed previousWhitelister, address indexed newWhitelister);

    constructor() {
        _whitelister = _msgSender();
    }

    modifier onlyWhitelister() {
        require(_whitelister == _msgSender() || owner() == _msgSender(), "Caller is not the whitelister");
        _;
    }

    function renounceWhitelister() external onlyWhitelister {
        emit WhitelisterTransferred(_whitelister, address(0));
        _whitelister = address(0);
    }

    function transferWhitelister(address newWhitelister) external onlyWhitelister {
        _transferWhitelister(newWhitelister);
    }

    function _transferWhitelister(address newWhitelister) internal {
        require(newWhitelister != address(0), "New whitelister is the zero address");
        emit WhitelisterTransferred(_whitelister, newWhitelister);
        _whitelister = newWhitelister;
    }

    /*
     * createLGEWhitelist - Call this after initial Token Generation Event (TGE)
     *
     * pairAddress - address generated from createPair() event on DEX
     * durations - array of durations (seconds) for each whitelist rounds
     * amountsMax - array of max amounts (TOKEN decimals) for each whitelist round
     *
     */

    function createLGEWhitelist(
        address pairAddress,
        uint256[] calldata durations,
        uint256[] calldata amountsMax
    ) external onlyWhitelister() {
        require(durations.length == amountsMax.length, "Invalid whitelist(s)");
        require(pairAddress != address(0), "Invalid pairAddress: ZERO");

        _lgePairAddress = pairAddress;

        if (durations.length > 0) {
            delete _lgeWhitelistRounds;

            for (uint256 i = 0; i < durations.length; i++) {
                WhitelistRound storage whitelistRound = _lgeWhitelistRounds.push();
                whitelistRound.duration = durations[i];
                whitelistRound.amountMax = amountsMax[i];
            }
        }
    }

    /*
     * modifyLGEWhitelistAddresses - Define what addresses are included/excluded from a whitelist round
     *
     * index - 0-based index of round to modify whitelist
     * duration - period in seconds from LGE event or previous whitelist round
     * amountMax - max amount (TOKEN decimals) for each whitelist round
     *
     */

    function modifyLGEWhitelist(
        uint256 index,
        uint256 duration,
        uint256 amountMax,
        address[] calldata addresses,
        bool enabled
    ) external onlyWhitelister() {
        require(index < _lgeWhitelistRounds.length, "Invalid index");
        require(amountMax > 0, "Invalid amountMax");

        if (duration != _lgeWhitelistRounds[index].duration) _lgeWhitelistRounds[index].duration = duration;

        if (amountMax != _lgeWhitelistRounds[index].amountMax) _lgeWhitelistRounds[index].amountMax = amountMax;

        for (uint256 i = 0; i < addresses.length; i++) {
            _lgeWhitelistRounds[index].addresses[addresses[i]] = enabled;
        }
    }

    /*
     *  getLGEWhitelistRound
     *
     *  returns:
     *
     *  1. whitelist round number ( 0 = no active round now )
     *  2. duration, in seconds, current whitelist round is active for
     *  3. timestamp current whitelist round closes at
     *  4. maximum amount a whitelister can purchase in this round
     *  5. is caller whitelisted
     *  6. how much caller has purchased in current whitelist round
     *
     */

    function getLGEWhitelistRound()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        )
    {
        if (_lgeTimestamp > 0) {
            uint256 wlCloseTimestampLast = _lgeTimestamp;

            for (uint256 i = 0; i < _lgeWhitelistRounds.length; i++) {
                WhitelistRound storage wlRound = _lgeWhitelistRounds[i];

                wlCloseTimestampLast = wlCloseTimestampLast + wlRound.duration;
                if (block.timestamp <= wlCloseTimestampLast)
                    return (
                        i + 1,
                        wlRound.duration,
                        wlCloseTimestampLast,
                        wlRound.amountMax,
                        wlRound.addresses[_msgSender()],
                        wlRound.purchased[_msgSender()]
                    );
            }
        }

        return (0, 0, 0, 0, false, 0);
    }

    /*
     * _applyLGEWhitelist - internal function to be called initially before any transfers
     *
     */

    function _applyLGEWhitelist(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (_lgePairAddress == address(0) || _lgeWhitelistRounds.length == 0) return;

        if (_lgeTimestamp == 0 && sender != _lgePairAddress && recipient == _lgePairAddress && amount > 0)
            _lgeTimestamp = block.timestamp;

        if (sender == _lgePairAddress && recipient != _lgePairAddress) {
            //buying

            (uint256 wlRoundNumber, , , , , ) = getLGEWhitelistRound();

            if (wlRoundNumber > 0) {
                WhitelistRound storage wlRound = _lgeWhitelistRounds[wlRoundNumber - 1];

                require(wlRound.addresses[recipient], "LGE - Buyer is not whitelisted");

                uint256 amountRemaining = 0;

                if (wlRound.purchased[recipient] < wlRound.amountMax)
                    amountRemaining = wlRound.amountMax - wlRound.purchased[recipient];

                require(amount <= amountRemaining, "LGE - Amount exceeds whitelist maximum");
                wlRound.purchased[recipient] = wlRound.purchased[recipient] + amount;
            }
        }
    }
}

contract TidexTokenWhitelisted is Ownable, IERC20, LGEWhitelisted {
    
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    
    constructor() {
        _name = "SOLDAO Token";
        _symbol = "SOLDAO";
        _decimals = 18;
        _totalSupply = 2022 * 10 ** 18;
        _balances[_msgSender()] = _totalSupply;
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function decimals() external view  returns (uint8) {
        return _decimals;
    }
   
    function symbol() external view  returns (string memory) {
        return _symbol;
    }
   
    function name() external view  returns (string memory) {
        return _name;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public  override  returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue)
        public
        
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );

        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _applyLGEWhitelist(sender, recipient, amount);
        
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_tokenContract);       
        token.transfer(msg.sender, _amount);
    }
     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function _burn(address from, uint value) internal {
        _balances[from] = _balances[from] - value;
        _totalSupply = _totalSupply - value;
        emit Transfer(from, address(0), value);
    }
}