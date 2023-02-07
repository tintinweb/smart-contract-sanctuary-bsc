/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: Unlicensed
/*
 * Copyright © 2020 reflect.finance. ALL RIGHTS RESERVED.
 * ***** ***
 */
pragma solidity ^0.8.18;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

    function _msgData() internal view virtual returns (bytes calldata) {
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract Paint is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    mapping(address => bool) private _isExcludedFromFee;
    uint256 public _holdersFee;
    uint256 private _prevHoldersFee;
    uint256 public _developmentFee;
    uint256 private _prevDevelopmentFee;
    uint256 public _paintersFee;
    uint256 private _prevPaintersFee;

    uint256 public _maxTxAmount;

    address public _circulationWalletAddress;
    address public _developmentWalletAddress;
    address public _paintersWalletAddress;
    address public _deadWalletAddress;

    constructor(
        address circulationWalletAddress,
        address developmentWalletAddress,
        address paintersWalletAddress,
        address deadWalletAddress
    ) {
        _name = "Paint";
        _symbol = "PAINT";
        _decimals = 18;

        uint256 MAX = ~uint256(0);
        _tTotal = 2 * (10**8) * (10**_decimals);
        _rTotal = (MAX - (MAX % _tTotal));

        _holdersFee = 4;
        _prevHoldersFee = _holdersFee;
        _developmentFee = 1;
        _prevDevelopmentFee = _developmentFee;
        _paintersFee = 1;
        _prevPaintersFee = _paintersFee;

        _maxTxAmount = (_tTotal * 5) / 1000;

        _circulationWalletAddress = circulationWalletAddress;
        _developmentWalletAddress = developmentWalletAddress;
        _paintersWalletAddress = paintersWalletAddress;
        _deadWalletAddress = deadWalletAddress;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_circulationWalletAddress] = true;
        _isExcludedFromFee[_developmentWalletAddress] = true;
        _isExcludedFromFee[_paintersWalletAddress] = true;
        _isExcludedFromFee[_deadWalletAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        uint256 currentRate = _getRate();
        uint256 tCirculationSupply = (_tTotal * 45) / 100;
        uint256 tBurntSupply = (_tTotal * 25) / 100;
        uint256 tToBurnSupply = (_tTotal * 25) / 100;
        uint256 tDevelopmentSupply = (_tTotal * 5) / 100;

        _rOwned[_circulationWalletAddress] = tCirculationSupply * currentRate;
        _rOwned[_deadWalletAddress] = tBurntSupply * currentRate;
        _rOwned[address(this)] = tToBurnSupply * currentRate;
        _rOwned[_developmentWalletAddress] = tDevelopmentSupply * currentRate;

        excludeAccount(_paintersWalletAddress);
        excludeAccount(_circulationWalletAddress);
        excludeAccount(address(this));

        emit Transfer(
            address(0),
            _circulationWalletAddress,
            tCirculationSupply
        );
        emit Transfer(address(0), _deadWalletAddress, tBurntSupply);
        emit Transfer(
            address(0),
            _developmentWalletAddress,
            tDevelopmentSupply
        );
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    // IBEP20 OVERRIDE END

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) external {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        external
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
        return rAmount.div(currentRate);
    }

    // ONLY OWNER

    function excludeAccount(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMaxTxAmountPercent(uint256 maxTxPerMile) external onlyOwner {
        require(
            maxTxPerMile <= 50,
            "Max amount of wallet must be a less than 5% total supply"
        );
        _maxTxAmount = (_tTotal * maxTxPerMile) / 1000;
    }

    function setHoldersFeePercent(uint256 tFee) external onlyOwner {
        require(tFee <= 5, "Holders fee must be a less than 5%");
        _holdersFee = tFee;
    }

    function setDevelopmentFeePercent(uint256 developmentFee)
        external
        onlyOwner
    {
        require(developmentFee <= 5, "Development fee must be a less than 5%");
        _developmentFee = developmentFee;
    }

    function setPaintersFeePercent(uint256 paintersFee) external onlyOwner {
        require(paintersFee <= 5, "Painters fee must be a less than 5%");
        _paintersFee = paintersFee;
    }

    function setCirculationWalletAddress(address newAddress)
        external
        onlyOwner
    {
        _circulationWalletAddress = newAddress;
    }

    function setDevelopmentWalletAddress(address newAddress)
        external
        onlyOwner
    {
        _developmentWalletAddress = newAddress;
    }

    function setPaintersWalletAddress(address newAddress) external onlyOwner {
        _paintersWalletAddress = newAddress;
    }

    function burn(uint256 tAmount) external onlyOwner {
        _removeAllFee();
        _transferFromExcluded(
            address(this),
            _deadWalletAddress,
            tAmount,
            false
        );
        _restoreAllFee();
    }

    function transferBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // PRIVATE

    receive() external payable {}

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

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
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
            uint256 tDevelopmentFee,
            uint256 tPainterFee
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tDevelopmentFee,
            tPainterFee,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tDevelopmentFee,
            tPainterFee
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
        uint256 tFee = tAmount.mul(_holdersFee).div(100);
        uint256 tDevelopmentFee = tAmount.mul(_developmentFee).div(100);
        uint256 tPainterFee = tAmount.mul(_paintersFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(_developmentFee).sub(
            _paintersFee
        );
        return (tTransferAmount, tFee, tDevelopmentFee, tPainterFee);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tDevelopmentFee,
        uint256 tPainterFee,
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
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rDevelopmentFee = tDevelopmentFee.mul(currentRate);
        uint256 rPainterFee = tPainterFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rDevelopmentFee).sub(
            rPainterFee
        );
        return (rAmount, rTransferAmount, rFee);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeDevelopment(uint256 tDevelopment) private {
        uint256 currentRate = _getRate();
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        _rOwned[_developmentWalletAddress] = _rOwned[_developmentWalletAddress]
            .add(rDevelopment);
        if (_isExcluded[_developmentWalletAddress])
            _tOwned[_developmentWalletAddress] = _tOwned[
                _developmentWalletAddress
            ].add(tDevelopment);
    }

    function _takePainters(uint256 tPainters) private {
        uint256 currentRate = _getRate();
        uint256 rPainters = tPainters.mul(currentRate);
        _rOwned[_paintersWalletAddress] = _rOwned[_paintersWalletAddress].add(
            rPainters
        );
        if (_isExcluded[_paintersWalletAddress])
            _tOwned[_paintersWalletAddress] = _tOwned[_paintersWalletAddress]
                .add(tPainters);
    }

    function _removeAllFee() private {
        _prevHoldersFee = _holdersFee;
        _prevDevelopmentFee = _developmentFee;
        _prevPaintersFee = _paintersFee;

        _holdersFee = 0;
        _developmentFee = 0;
        _paintersFee = 0;
    }

    function _restoreAllFee() private {
        _holdersFee = _prevHoldersFee;
        _developmentFee = _prevDevelopmentFee;
        _paintersFee = _prevPaintersFee;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (
            !(sender == owner() ||
                recipient == owner() ||
                sender == _circulationWalletAddress ||
                recipient == _circulationWalletAddress ||
                sender == _developmentWalletAddress ||
                recipient == _developmentWalletAddress ||
                sender == _paintersWalletAddress ||
                recipient == _paintersWalletAddress ||
                recipient == _deadWalletAddress)
        )
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
            _removeAllFee();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee);
        } else {
            _transferStandard(sender, recipient, amount, takeFee);
        }

        if (!takeFee) _restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tDevelopmentFee,
            uint256 tPainterFee
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (takeFee) {
            _takeDevelopment(tDevelopmentFee);
            _takePainters(tPainterFee);
            _reflectFee(rFee, tFee);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tDevelopmentFee,
            uint256 tPainterFee
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (takeFee) {
            _takeDevelopment(tDevelopmentFee);
            _takePainters(tPainterFee);
            _reflectFee(rFee, tFee);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tDevelopmentFee,
            uint256 tPainterFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (takeFee) {
            _takeDevelopment(tDevelopmentFee);
            _takePainters(tPainterFee);
            _reflectFee(rFee, tFee);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tDevelopmentFee,
            uint256 tPainterFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (takeFee) {
            _takeDevelopment(tDevelopmentFee);
            _takePainters(tPainterFee);
            _reflectFee(rFee, tFee);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }
}