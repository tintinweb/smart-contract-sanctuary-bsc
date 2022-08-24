// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ISWAP.sol";
import "./USDTContract.sol";
import "./KSWAPContract.sol";
import "./SafeMath.sol";
import "./CPEContract.sol";
import "./KingContract.sol";

contract SWAP is ISWAP, KSWAPContract, USDTContract, CPEContract, KingContract {
    address private sender;
    uint256 private _tokenTotalSupply;
    uint256 private _kTotal;
    uint256 private _cpeTotal;
    uint256 private _businessBuyCnt = 0;
    address private _kswapAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private _project1Address;
    address private _project2Address;
    mapping(address => Orders[]) private _buyRecord;
    mapping(address => Orders[]) private _sellRecord;

    using SafeMath for uint256;

    constructor() {
        sender = msg.sender;
        _approveUSDT(_kswapAddress);
    }

    modifier onlyMinter() {
        require(
            msg.sender == sender,
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function initPool(uint256 uAmount)
        external
        override
        onlyMinter
        returns (bool)
    {
        require(_businessBuyCnt == 0, "not Cnt");
        uint256 amountOut = _get_U_K_AmountsOut(uAmount);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        _transferFromUSDT(msg.sender, address(this), uAmount);
        uint256[] memory amounts = _swap_U_K_ExactTokensForTokens(
            uAmount,
            amountOutMin,
            address(this)
        );
        _kTotal = _kTotal.add(amounts[1]);
        _cpeTotal = _cpeTotal.add(uAmount);
        _businessBuyCnt = _businessBuyCnt.add(1);
        return true;
    }

    function getCurrentPrice() external view override returns (uint256) {
        if (_cpeTotal == 0) {
            return 0;
        } else {
            return _kTotal.mul(1000000).div(_cpeTotal);
        }
    }

    function getKTotal() external view override returns (uint256) {
        return _kTotal;
    }

    function getCPETotal() external view override returns (uint256) {
        return _cpeTotal;
    }

    function getHistoryBuyOrder()
        external
        view
        override
        returns (Orders[] memory)
    {
        return _buyRecord[msg.sender];
    }

    function getHistorySellOrder()
        external
        view
        override
        returns (Orders[] memory)
    {
        return _sellRecord[msg.sender];
    }

    function sellCPE(uint256 amount) external override returns (bool) {
        require(amount > 0);
        require(_project1Address != address(0));
        require(_project2Address != address(0));
        uint256 balanceCPE = _balanceOfCPE(msg.sender);
        require(balanceCPE >= amount, "Insufficient balance");
        address cpeSender = _getSenderCPE();
        _transferFromCPE(
            msg.sender,
            cpeSender,
            amount.mul(970000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _project1Address,
            amount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _project2Address,
            amount.mul(15000).div(1000000)
        );
        uint256 cepPrice = _getCurrentPrice();
        uint256 kAmount = amount.mul(900000).mul(cepPrice).div(1000000).div(
            1000000
        );
        _transferKing(msg.sender, kAmount);
        _kTotal = _kTotal.sub(kAmount);
        _cpeTotal = _cpeTotal.sub(amount.mul(970000).div(1000000));
        _sellRecord[msg.sender].push(
            Orders(amount, kAmount.div(amount), kAmount)
        );
        return true;
    }

    function buyCPE(uint256 orderNo) external override returns (bool) {
        require(orderNo > 0);
        require(_project1Address != address(0));
        require(_project2Address != address(0));
        uint256 uAmount = 25000000000000000000;
        address cpeSender = _getSenderCPE();
        address tempAddress = msg.sender;
        address recommenderAddress = 0xb8b660f461556d3B9a9A0306dAc9Cc7fAd332532;
        address businessAddress = 0xb8b660f461556d3B9a9A0306dAc9Cc7fAd332532;
        address businessRecommenderAddress = 0xb8b660f461556d3B9a9A0306dAc9Cc7fAd332532;
        uint256 amountOut = _get_U_K_AmountsOut(uAmount);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        _transferFromUSDT(tempAddress, address(this), uAmount);
        uint256[] memory amounts = _swap_U_K_ExactTokensForTokens(
            uAmount,
            amountOutMin,
            address(this)
        );
        uint256 kAmount = amounts[1];
        uint256 cpePrice = _getCurrentPrice();
        uint256 cpeAmount = kAmount.mul(1000000).div(cpePrice);
        uint256 mySelfNumber = cpeAmount.mul(688000).div(1000000);
        _transferFromCPE(cpeSender, tempAddress, mySelfNumber);
        _transferFromCPE(
            cpeSender,
            recommenderAddress,
            cpeAmount.mul(172000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            businessAddress,
            cpeAmount.mul(30000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            businessRecommenderAddress,
            cpeAmount.mul(10000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            _project1Address,
            cpeAmount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            _project2Address,
            cpeAmount.mul(15000).div(1000000)
        );
        _kTotal = _kTotal.add(amounts[1]);
        _cpeTotal = _cpeTotal.add(cpeAmount.mul(930000).div(1000000));
        _buyRecord[tempAddress].push(
            Orders(mySelfNumber, kAmount.div(mySelfNumber), kAmount)
        );
        return true;
    }

    function setProject1Address(address project1Address)
        external
        override
        onlyMinter
        returns (address)
    {
        _project1Address = project1Address;
        return _project1Address;
    }

    function setProject2Address(address project2Address)
        external
        override
        onlyMinter
        returns (address)
    {
        _project2Address = project2Address;
        return _project2Address;
    }

    function _getCurrentPrice() internal view returns (uint256) {
        if (_cpeTotal == 0) {
            return 0;
        } else {
            return _kTotal.mul(1000000).div(_cpeTotal);
        }
    }

    address private _paramSignAddress;

    function setParamSignAddress(address paramSignAddress)
        internal
        returns (bool)
    {
        _paramSignAddress = paramSignAddress;
        return true;
    }

    function pubVerify(string memory data, bytes memory signature)
        internal
        view
        returns (bool)
    {
        require(
            _paramSignAddress != address(0),
            "paramSignAddress the zero address"
        );
        bytes32 dataHash = keccak256(abi.encodePacked(data));
        bool r = _verify(dataHash, signature, _paramSignAddress);
        return r;
    }

    function _verify(
        bytes32 dataHash,
        bytes memory signature,
        address paramSignAddress
    ) internal pure returns (bool) {
        return
            _tryRecover(_toEthSignedMessageHash(dataHash), signature) ==
            paramSignAddress;
    }

    function _toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function _tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return ecrecover(hash, v, r, s);
        } else {
            return (address(0));
        }
    }
}