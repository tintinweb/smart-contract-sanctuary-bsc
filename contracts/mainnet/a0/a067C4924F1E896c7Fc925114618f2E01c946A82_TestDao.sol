// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./Ownable.sol";
import "./IHashFreeDao.sol";
import "./ERC20Detailed.sol";

contract TestDao is ERC20Detailed, Pausable, Ownable, IHashFreeDao {
    uint256 private _totalSupply;
    IERC20 private usdt;

    uint256 public ReferralFee = 1;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public operators;
    mapping(address => bool) public minters;
    mapping(address => bool) public blackList;

    // origin => referrals, should be private
    mapping(address => address[]) private referrals;
    mapping(address => address[]) private underlings;
    mapping(address => uint8) private referralCount;
    mapping(address => uint256) private underCount;
    // not allowed join relation
    mapping(address => bool) public singles;

    event SetReferral(address origin, address referral);
    event Betray(address origin);

    modifier onlyOperator() {
        require(operators[_msgSender()], "only operator");
        _;
    }

    modifier onlyMinter() {
        require(minters[_msgSender()], "only minter");
        _;
    }

    constructor(IERC20 _payToken, address fina) ERC20Detailed("TestCoin", "TestCoin", 0) {
        setOperator(owner(), true);
        setMinter(owner(), true);
        _mint(fina, 2_000_000);
        singles[address(this)] = true;
        singles[fina] = true;
        usdt = _payToken;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getRelations(address _address)
        external
        view
        override
        returns (uint8 count, address[] memory)
    {
        return (referralCount[_address], referrals[_address]);
    }

    function getUnderlings(address _address)
        public
        view
        returns (uint256 count, address[] memory)
    {
        return (underCount[_address], underlings[_address]);
    }

    function payToken() public view override returns (address) {
        return address(usdt);
    }

    function setOperator(address operator, bool flag) public onlyOwner {
        operators[operator] = flag;
    }

    function setReferralFee(uint256 fee) public onlyOwner {
        ReferralFee = fee;
    }

    function setMinter(address minter, bool flag) public onlyOwner {
        minters[minter] = flag;
        if (flag) {
            singles[minter] = flag; // minter should be single
        }
    }

    function setBlackList(address[] memory blacks, bool flag) public onlyOperator {
        for (uint256 i = 0; i < blacks.length; ++i) {
            blackList[blacks[i]] = flag;
        }
    }

    // @Notice: init set must before user get hashfree
    function setSingles(address[] memory _singles, bool flag) public onlyOperator {
        for (uint256 i = 0; i < _singles.length; ++i) {
            singles[_singles[i]] = flag;
        }
    }

    function setReferral(address _origin, address _referral)
        public
        override
        onlyOperator
    {
        if (canBeReferral(_origin, _referral)) _setReferral(_origin, _referral);
    }

    function _setReferral(address _origin, address _referral) private {
        if (singles[_origin] || singles[_referral]) {
            return;
        }
        // set referral to origin's relation
        require(underCount[_origin] == 0, "origin has underlings");
        require(referralCount[_origin] == 0, "origin has referral");
        referrals[_origin].push(_referral);
        referralCount[_origin] += 1;
        
        // get referral's relation transparent to origin
        uint8 count = referralCount[_referral];
        if (count > 0) {
            count = count >= 9 ? 9 : count;
            referralCount[_origin] += count;
            for (uint256 i = 0; i < count; i++) {
                address uperReferral = referrals[_referral][i];
                if (uperReferral != address(0)) {
                    referrals[_origin].push(uperReferral);
                }
            }
        }
        emit SetReferral(_origin, _referral);
        // record immdeatly uplings
        underlings[_referral].push(_origin);
        underCount[_referral] += 1;
    }

    function betray(address target) public onlyOperator {
        uint8 count = referralCount[target];
        require(count > 0, "no need betray");
        delete referrals[target];
        referralCount[target] = 0;
        emit Betray(target);
    }

    function canBeReferral(address _origin, address _referral)
        public
        view
        returns (bool)
    {
        return (!singles[_origin] &&
            !singles[_referral] &&
            referralCount[_origin] == 0 &&
            underCount[_origin] == 0);
    }

    function withdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    // ==========  detail for erc20 ==========
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

    function mint(address spender, uint256 amount)
        public
        onlyMinter
        returns (bool)
    {
        _mint(spender, amount);
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount >= 1, "invalid amount");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        uint256 referralFee;
        // if "to" not referral & underlings, "from" become "to"'s referral
        if (canBeReferral(to, from)) {
            _setReferral(to, from);
            referralFee = ReferralFee;
        }
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        amount -= referralFee; // reduce referral fee
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    // without trigger referral
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal whenNotPaused {
        require(!blackList[from] && !blackList[to], "in black list");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}