/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface TokenTransfer {
    function transfer(address recipient, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract Dividend {
    using SafeMath for uint256;

    address _owner;

    mapping(string => address) coinTypeMaping;

    mapping(uint256 => address) public _player;

    mapping(uint256 => uint256) public BL;

    // USDT-0x55d398326f99059fF775485246999027B3197955
    // USDC-0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
    // BUSD-0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    constructor() {
        _owner = msg.sender;
        coinTypeMaping["USDT"] = 0x55d398326f99059fF775485246999027B3197955;
        coinTypeMaping["USDC"] = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        coinTypeMaping["BUSD"] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    }

    function setCoinTypeMapping(string memory _coinType, address _coinTypeAddr)
        external
        onlyOwner
    {
        coinTypeMaping[_coinType] = _coinTypeAddr;
    }

    function getCoinTypeMapping(string memory _coinType)
        public
        view
        returns (address)
    {
        return coinTypeMaping[_coinType];
    }

    function getERC20Address(string memory _coinType)
        public
        view
        returns (TokenTransfer)
    {
        require(bytes(_coinType).length != 0, "1");
        address _remoteAddr = coinTypeMaping[_coinType];
        require(_remoteAddr != address(0), "2");
        TokenTransfer _tokenTransfer = TokenTransfer(_remoteAddr);
        return _tokenTransfer;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function setDividendAddressAndBlSingle(
        address NodeAddress,
        uint256 index,
        uint256 NodeBL
    ) public onlyOwner {
        BL[index] = NodeBL;
        _player[index] = NodeAddress;
    }

    function setDividendAddressAndBlMul(
        address[] calldata NodeAddress,
        uint256[] calldata NodeBL,
        uint256[] calldata index
    ) public onlyOwner {
        for (uint256 i = 0; i < NodeBL.length; i++) {
            uint256 bl = NodeBL[i];
            address add = NodeAddress[i];
            uint256 indexx = index[i];
            BL[indexx] = bl;
            _player[indexx] = add;
        }
    }

    receive() external payable {}

    function withdrawSymbol(
        uint256 amount,
        string memory coinType,
        uint256 len
    ) public onlyOwner {
        require(len > 0);
        TokenTransfer _tokenTransfer = getERC20Address(coinType);
        for (uint256 i = 0; i < len; i++) {
            address account = _player[i];
            if (account != address(0)) {
                _tokenTransfer.transfer(account, amount.mul(BL[i]).div(100));
            }
        }
    }

    function withdrawBnb(uint256 amount, uint256 len) public payable onlyOwner {
        require(len > 0);
        require(msg.value == amount, "msg value is must = amount");
        require(
            amount <= address(this).balance,
            "current contract balance is not enough"
        );
        for (uint256 i = 0; i < len; i++) {
            address account = _player[i];
            if (account != address(0)) {
                address payable _receipt = payable(address(uint160(account)));
                _receipt.transfer(amount.mul(BL[i]).div(100));
            }
        }
    }
}