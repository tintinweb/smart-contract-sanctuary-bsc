// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./IERC20.sol";
import "./Context.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IMyNFT.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

contract ERC20 is Context, IERC20, Ownable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct Vesting {
        uint256 amount;
        uint256 deadline;
    }

    mapping (address => Vesting) public vestings;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => bool) private usedNonces;

    uint256 private _totalSupply = 0;
    uint8 private _decimals = 18;
    string private _name = "TokenVH";
    string private _symbol = "VH";

    MyNFT private _mainContract;

    address private _verifier;

    uint256 private mintInterval;
    mapping(address => uint256) private lastMinted;

    address private receiverWallet = 0x3fD8B95f2dB23B17C4c2275E04A73803390f1482;

    uint8 private percentBurn = 10;
    uint8 private percentTransfer = 90;

    address constant premintWallet = 0x3fD8B95f2dB23B17C4c2275E04A73803390f1482;
    uint8 constant premintPercent = 50;
    uint256 amountVesting;

    IERC20 private stableToken;

    event ItemBought(address indexed buyer, uint256 _nftId, uint256 _amount, string args);
    event ClaimTokens(address indexed to, uint256 _amount, uint256 _mode, uint256 _nonce);

    constructor(address cOwner, address verifier, uint256 _amount) Ownable (cOwner) {
        require(_amount > 0, "Cant be 0 amount mint");
        require(verifier != address(0), "Zero address for verifier");

        _verifier = verifier;

        uint256 amountPremint = _amount.div(100).mul(premintPercent);

        _balances[premintWallet] = amountPremint;

        amountVesting = _amount.sub(amountPremint);

        _totalSupply += _amount;


        addVesting(0x3fD8B95f2dB23B17C4c2275E04A73803390f1482, 10000, block.timestamp + 3 * 30 days);
    }

    function setStableToken(address _stableToken) external onlyOwner {
        require(_stableToken != address(0), "Stable token contract zero address");
        require(_stableToken != address(this), "Stable token contract current address");

        stableToken = IERC20(_stableToken);
    }

    function buyItem(bool _currToken, uint256 _amount, bool _mode, uint256 nonce, bytes memory sig, string memory _args) external {
        require(_amount > 0, "Token amount cannot be zero");

        address addressToken = address(this);

        if (_currToken) {
            require(_balances[_msgSender()] >= _amount, "Insufficient token balance to buy item");
        } else {
            require(address(stableToken) != address(0), "Not set stable token contract");
            require(stableToken.balanceOf(_msgSender()) >= _amount,"Insufficient ERC20 tokens amount to buy");
            require(stableToken.allowance(_msgSender(), address(this)) >= _amount, "Amount is not allowed by ERC20 holder");
            addressToken = address(stableToken);
        }

        require(!usedNonces[nonce]);
        bytes32 message = prefixed(keccak256(abi.encodePacked(_currToken, _amount, _mode, nonce, addressToken, _args)));
        address signer = recoverSigner(message, sig);
        require(signer ==_verifier, "Unauthorized transaction");
        usedNonces[nonce] = true;

        if (_currToken) {
            buyFromCurToken(_amount, _mode, _args);
        } else {
            buyFromStableToken(_amount, _mode, _args);
        }

    }

    function buyFromCurToken(uint256 _amount, bool _mode, string memory _args) private  {
        uint256 amountBurn = _amount.div(100).mul(percentBurn);
        uint256 amountTransfer = _amount.div(100).mul(percentTransfer);

        _balances[_msgSender()] = _balances[_msgSender()] - amountTransfer;
        _burn(_msgSender(), amountBurn);

        _balances[receiverWallet] = _balances[receiverWallet] + amountTransfer;

        if (!_mode) {
            uint256 result = _mainContract.createFromERC20(_msgSender());
            emit ItemBought(_msgSender(), result, _amount, _args);
        } else {
            emit ItemBought(_msgSender(), 0, _amount, _args);
        }

        emit Transfer(_msgSender(), address(this), _amount);
    }

    function buyFromStableToken(uint256 _amount, bool _mode, string memory _args) private  {
        stableToken.safeTransferFrom(_msgSender(), receiverWallet, _amount);

        if (!_mode) {
            uint256 result = _mainContract.createFromERC20(_msgSender());
            emit ItemBought(_msgSender(), result, _amount, _args);
        } else {
            emit ItemBought(_msgSender(), 0, _amount, _args);
        }

        emit Transfer(_msgSender(), address(stableToken), _amount);
    }


    function addVesting(address _wallet, uint256 _amount, uint256 _deadline) private {
        require(_wallet != address(0), "Zero address");
        require(_amount > 0, "Amount cant be 0");
        require(vestings[_wallet].amount == 0, "Vesting is set");

        Vesting memory vst = Vesting({
                                    amount: _amount,
                                    deadline: _deadline
                                });
                                
        vestings[_wallet] = vst;
    }

    function setReceiverWalet(address _receiverWallet) external onlyOwner {
        require(_receiverWallet != address(0), "Zero address for receiver wallet");

        receiverWallet = _receiverWallet;
    }

    function setShare(uint8 _percentBurn, uint8 _percentTransfer) external onlyOwner {
        require(_percentBurn + _percentTransfer == 100, "Must be 100%");

        percentBurn = _percentBurn;
        percentTransfer = _percentTransfer;
    }

    function mint(uint256 _amount, uint256 nonce, bytes memory sig, string memory _args) external {
        require(!usedNonces[nonce]);

        uint256 currTime = block.timestamp;

        require(lastMinted[_msgSender()] + mintInterval <= currTime, "Mint not available");

        bytes32 message = prefixed(keccak256(abi.encodePacked(_amount, nonce, address(this), _args)));
        address signer = recoverSigner(message, sig);
        require(signer ==_verifier, "Unauthorized transaction");
        usedNonces[nonce] = true;

        _mint(_msgSender(), _amount);
        lastMinted[_msgSender()] = currTime;
    }

    function burn(uint256 _amount) external {
        _burn(_msgSender(), _amount);
    }

    function setMintInterval(uint256 _mintInterval) external onlyOwner {
        mintInterval = _mintInterval;
    }

    function setMainNFT(address _contract) external onlyOwner {
        require(_contract != address(0), "Zero address for NFT contract is not acceptable");
        _mainContract = MyNFT(_contract);

    }
    
    function claim() external {
        require(vestings[_msgSender()].amount > 0, "Vesting is not avalible");
        require(vestings[_msgSender()].deadline >= block.timestamp, "Vesting is lock");

        _balances[_msgSender()] += vestings[_msgSender()].amount;
        amountVesting -= vestings[_msgSender()].amount;

        emit Transfer(address(this), _msgSender(), vestings[_msgSender()].amount);    

        vestings[_msgSender()].amount = 0;
    }
    

    function recoverSigner(bytes32 message, bytes memory sig) public pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    public
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }



    function name() external view virtual override returns (string memory) {
        return _name;
    }


    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }


    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }



    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


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


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }


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


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _beforeTokenTransfer(
            address from,
            address to,
            uint256 amount
        ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


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
}