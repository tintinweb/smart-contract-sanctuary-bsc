/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Paws is Context, IBEP20, Ownable {
    mapping(address => uint256) private _reflectionBalances;
    mapping(address => uint256) private _normalBalances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 private _tFeeTotal;

    string private _name = "Paws";
    string private _symbol = "PAWS";
    uint8 private _decimals = 18;

    address public _marketingAndDonationWallet;

    uint256 public _burnFee = 5;
    uint256 private _previousBurnFee = _burnFee;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _marketingAndDonationFee = 3;
    uint256 private _previousMarketingAndDonationFee = _marketingAndDonationFee;

    constructor() {
        _reflectionBalances[_msgSender()] = _rTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAndDonationWallet] = true;

        _marketingAndDonationWallet = 0xC9654530E08907D0Ea73E17fa8EF8964129A3dB7;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _normalBalances[account];
        return tokenFromReflection(_reflectionBalances[account]);
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalances[_excluded[i]] > rSupply ||
                _normalBalances[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _reflectionBalances[_excluded[i]];
            tSupply = tSupply - _normalBalances[_excluded[i]];
        }

        if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);

        return (rSupply, tSupply);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _marketingAndDonationFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousMarketingAndDonationFee = _marketingAndDonationFee;
        _previousBurnFee = _burnFee;

        _taxFee = 0;
        _marketingAndDonationFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _marketingAndDonationFee = _previousMarketingAndDonationFee;
        _burnFee = _previousBurnFee;
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketingAndDonation,
            uint256 tBurnFee
        ) = _getValues(tAmount);
        _normalBalances[sender] = _normalBalances[sender] - tAmount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            rTransferAmount;
        _takeMarketingAndDonation(tMarketingAndDonation);
        _reflectFee(rFee, tFee);
        _takeBurningFee(tBurnFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketingAndDonation,
            uint256 tBurnFee
        ) = _getValues(tAmount);
        _reflectionBalances[sender] = _reflectionBalances[sender] - rAmount;
        _normalBalances[recipient] =
            _normalBalances[recipient] +
            tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            rTransferAmount;
        _takeMarketingAndDonation(tMarketingAndDonation);
        _reflectFee(rFee, tFee);
        _takeBurningFee(tBurnFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketingAndDonation,
            uint256 tBurnFee
        ) = _getValues(tAmount);
        _reflectionBalances[sender] = _reflectionBalances[sender] - rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            rTransferAmount;
        _takeMarketingAndDonation(tMarketingAndDonation);
        _reflectFee(rFee, tFee);
        _takeBurningFee(tBurnFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketingAndDonation,
            uint256 tBurnFee
        ) = _getValues(tAmount);
        _normalBalances[sender] = _normalBalances[sender] - tAmount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - rAmount;
        _normalBalances[recipient] =
            _normalBalances[recipient] +
            tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            rTransferAmount;
        _takeMarketingAndDonation(tMarketingAndDonation);
        _reflectFee(rFee, tFee);
        _takeBurningFee(tBurnFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketingAndDonation,
            uint256 tBurnFee
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tMarketingAndDonation,
            tBurnFee,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tMarketingAndDonation,
            tBurnFee
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tMarketingAndDonation = calculateMarketingAndDonationFee(
            tAmount
        );
        uint256 tBurnFee = calculateBurnFee(tAmount);
        uint256 tTransferAmount = tAmount -
            tFee -
            tMarketingAndDonation -
            tBurnFee;
        return (tTransferAmount, tFee, tMarketingAndDonation, tBurnFee);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxFee) / (10**2);
    }

    function calculateMarketingAndDonationFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _marketingAndDonationFee) / (10**2);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _burnFee) / (10**2);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tMarketingAndDonation,
        uint256 tBurnFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketingAndDonation = tMarketingAndDonation * currentRate;
        uint256 rBurnFee = tBurnFee * currentRate;
        uint256 rTransferAmount = rAmount -
            rFee -
            rMarketingAndDonation -
            rBurnFee;
        return (rAmount, rTransferAmount, rFee);
    }

    function _takeMarketingAndDonation(uint256 tMarketingAndDonation) private {
        uint256 currentRate = _getRate();
        uint256 rMarketingAndDonation = tMarketingAndDonation * currentRate;
        _reflectionBalances[_marketingAndDonationWallet] =
            _reflectionBalances[_marketingAndDonationWallet] +
            rMarketingAndDonation;
        if (_isExcluded[_marketingAndDonationWallet])
            _normalBalances[_marketingAndDonationWallet] =
                _normalBalances[_marketingAndDonationWallet] +
                tMarketingAndDonation;
    }

    function _takeBurningFee(uint256 tBurnFee) private {
        uint256 currentRate = _getRate();
        uint256 rBurnFee = tBurnFee * currentRate;
        _reflectionBalances[_burnAddress] =
            _reflectionBalances[_burnAddress] +
            rBurnFee;
        if (_isExcluded[_burnAddress])
            _normalBalances[_burnAddress] =
                _normalBalances[_burnAddress] +
                tBurnFee;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            (_allowances[sender][_msgSender()] - amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            (_allowances[_msgSender()][spender] + addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            (_allowances[_msgSender()][spender] - subtractedValue)
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_reflectionBalances[account] > 0) {
            _normalBalances[account] = tokenFromReflection(
                _reflectionBalances[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _normalBalances[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    receive() external payable {}

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
}