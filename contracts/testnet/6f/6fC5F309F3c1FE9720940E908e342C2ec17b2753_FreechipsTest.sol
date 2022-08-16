// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Pausable.sol";
import "./Ownable.sol";
import "./ERC20Detailed.sol";

interface ICrowdSale {
    function deadline() external view returns (uint256);
}

contract FreechipsTest is ERC20Detailed, Pausable, Ownable {
    ICrowdSale public csadr;
    uint256 public claim_end;
    uint256 private _totalSupply;
    uint256 public constant INIT_SUPPLY = 10_000_000;
    uint8 public constant DECIMALS = 18;
    uint256 public claim_amount = 1000;
    mapping(address => bool) public is_claim;
    mapping(address => bool) public whiteList;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    bool private _inClaim;

    modifier callerIsUser() {
        require(tx.origin == _msgSender(), "the caller is another contract");
        _;
    }
    modifier beforeEnd() {
        require(block.timestamp <= claim_end, "claim ended");
        _;
    }
    modifier lockClaim() {
        require(!_inClaim, "alreadr in claim");
        _inClaim = true;
        _;
        _inClaim = false;
    }

    constructor(address _fina, address _crowdsale)
        ERC20Detailed("HashCashTest", "HCTest", DECIMALS)
    {
        csadr = ICrowdSale(_crowdsale);
        claim_end = csadr.deadline() + 15 days;
        uint256 initsupply = INIT_SUPPLY * 10**DECIMALS;
        _balances[_fina] = initsupply;
        whiteList[_fina] = true;
        whiteList[address(this)] = true;
        emit Transfer(address(0), _fina, initsupply);
    }

    function claim() external callerIsUser beforeEnd lockClaim {
        require(!is_claim[_msgSender()], "already claimed");
        is_claim[_msgSender()] = true;
        _mint(_msgSender(), getClaimAmount());
    }

    function setClaimEndat(uint256 _endtime) external onlyOwner {
        claim_end = _endtime;
    }

    // Note: without decimals
    function setClaimAmount(uint256 _amount) external onlyOwner {
        claim_amount = _amount;
    }

    function setWhiteList(address _white, bool _flag) external onlyOwner {
        whiteList[_white] = _flag;
    }

    function ownerWithdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    function setWhiteLists(address[] memory _whites, bool _flag)
        external
        onlyOwner
    {
        require(_whites.length > 0, "invalid length");
        for (uint256 i = 0; i < _whites.length; i++) {
            whiteList[_whites[i]] = _flag;
        }
    }

    function checkClaim(address _address) public view returns (bool) {
        return is_claim[_address];
    }

    function getClaimAmount() public view returns (uint256) {
        return claim_amount * 10**decimals();
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(
            from != address(0) || to != address(0),
            "ERC20: transfer from the zero address"
        );
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        // Release allowance change when spender equals exchange
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal whenNotPaused {
        require(whiteList[from] || whiteList[to], "not in white list");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}