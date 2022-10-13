/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
contract Ownable {
    address public owner;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// 接口
interface IETEDIDNFT {
    function mintDIDNFT(address user, uint256 amount) external;
    function mintCrystals(address user, uint256 amount) external;
    function burnCrystals(address user, uint256 amount) external;
}


// 铸造DIDNFT合约
contract MinterDIDNF is Ownable {
    using SafeMath for uint256;

    // token地址
    address public ETEOLD;
    address public USDT;
    address public ETT;
    address public ETES;
    address public ETE;
    // 设置是否可以用于铸造DIDNFT和价格。铸造水晶和价格。
    mapping(address => ShapeDIDNFT) public payDIDNFT;  // 总4个
    mapping(address => ShapeCrystal) public payCrystal; // 总2个
    struct ShapeDIDNFT {
        uint256 status;  // 是否可以购买。0=不支持，1=关闭支付，2=正常支付
        uint256 price1;  // 普通DIDNFT价格
        uint256 price2;  // 高级DIDNFT价格
    }
    struct ShapeCrystal {
        uint256 status;  // 是否可以购买。0=不支持，1=关闭支付，2=正常支付
        uint256 price;   // 价格
    }
    // 收币地址
    address public leader;
    // nft合约地址
    address public eteDIDNFT;


    constructor(
        address owner_,
        address leader_,
        address eteDIDNFT_,
        address ETEOLD_,
        address USDT_,
        address ETT_,
        address ETES_,
        address ETE_
        ) Ownable(owner_) {
        leader = leader_;
        eteDIDNFT = eteDIDNFT_;

        ETEOLD = ETEOLD_;
        USDT = USDT_;
        ETT = ETT_;
        ETES = ETES_;
        ETE = ETE_;
        // 设置为铸造DIDNFT
        uint256 _defaultPrice = 2 * (10**18);  // 默认价格
        uint256 _defaultPrice2 = 5 * (10**18);
        payDIDNFT[USDT] = ShapeDIDNFT({status: 2, price1: _defaultPrice, price2: _defaultPrice2});
        payDIDNFT[ETEOLD] = ShapeDIDNFT({status: 2, price1: _defaultPrice, price2: _defaultPrice2});
        payDIDNFT[ETT] = ShapeDIDNFT({status: 2, price1: _defaultPrice, price2: _defaultPrice2});
        payDIDNFT[ETE] = ShapeDIDNFT({status: 1, price1: _defaultPrice, price2: _defaultPrice2});
        // 设置为铸造水晶
        payCrystal[ETES] = ShapeCrystal({status: 2, price: _defaultPrice});
        payCrystal[ETE] = ShapeCrystal({status: 1, price: _defaultPrice});
    }

    // 开启或关闭DIDNFT铸造的支付代币
    function setPayDIDNFTStatus(address token, uint256 status) public onlyOwner {
        require(payDIDNFT[token].status == 1 || payDIDNFT[token].status == 2, "token not exist");
        require(status == 1 || status == 2, "status error");
        payDIDNFT[token].status = status;
    }

    // 开启或关闭水晶铸造的支付代币
    function setPayCrystalStatus(address token, uint256 status) public onlyOwner {
        require(payCrystal[token].status == 1  || payCrystal[token].status == 2, "token not exist");
        require(status == 1 || status == 2, "status error");
        payCrystal[token].status = status;
    }

    // 设置铸造DIDNFT的价格
    function setPayDIDNFTPrice(address token, uint256 price1, uint256 price2) public onlyOwner {
        require(payDIDNFT[token].status == 1 || payDIDNFT[token].status == 2, "token not exist");
        require(price1 > 0, "price1 is zero");
        require(price2 > 0, "price2 is zero");
        payDIDNFT[token].price1 = price1;
        payDIDNFT[token].price2 = price2;
    }

    // 设置铸造水晶的价格
    function setPayCrystalPrice(address token, uint256 price) public onlyOwner {
        require(payCrystal[token].status == 1 || payCrystal[token].status == 2, "token not exist");
        require(price > 0, "price is zero");
        payCrystal[token].price = price;
    }

    // 设置收币地址
    function setLeader(address newLeader) public onlyOwner {
        require(newLeader != address(0), "zero address error");
        leader = newLeader;
    }

    // 设置eteDIDNFT地址
    function setEteDIDNFT(address newEteDIDNFT) public onlyOwner {
        require(newEteDIDNFT != address(0), "zero address error");
        eteDIDNFT = newEteDIDNFT;
    }

    // 查询DIDNFT铸造的全部币种和可支付状态和价格
    function getAllPayDIDNFT() public view returns(address[] memory tokens, ShapeDIDNFT[] memory shapeDIDNFTs) {
        uint256 len = 4;
        tokens = new address[](len);
        shapeDIDNFTs = new ShapeDIDNFT[](len);
        tokens[0] = USDT;
        tokens[1] = ETEOLD;
        tokens[2] = ETT;
        tokens[3] = ETE;
        shapeDIDNFTs[0] = ShapeDIDNFT({status: payDIDNFT[USDT].status, price1: payDIDNFT[USDT].price1, price2: payDIDNFT[USDT].price2});
        shapeDIDNFTs[1] = ShapeDIDNFT({status: payDIDNFT[ETEOLD].status, price1: payDIDNFT[ETEOLD].price1, price2: payDIDNFT[ETEOLD].price2});
        shapeDIDNFTs[2] = ShapeDIDNFT({status: payDIDNFT[ETT].status, price1: payDIDNFT[ETT].price1, price2: payDIDNFT[ETT].price2});
        shapeDIDNFTs[3] = ShapeDIDNFT({status: payDIDNFT[ETE].status, price1: payDIDNFT[ETE].price1, price2: payDIDNFT[ETE].price2});
    }

    // 查询水晶铸造的全部币种和可支付状态和价格
    function getAllPayCrystal() public view returns(address[] memory tokens, ShapeCrystal[] memory shapeCrystals) {
        uint256 len = 2;
        tokens = new address[](len);
        shapeCrystals = new ShapeCrystal[](len);
        tokens[0] = ETES;
        tokens[1] = ETE;
        shapeCrystals[0] = ShapeCrystal({status: payCrystal[ETES].status, price: payCrystal[ETES].price});
        shapeCrystals[1] = ShapeCrystal({status: payCrystal[ETE].status, price: payCrystal[ETE].price});
    }

    // 使用代币铸造DIDNFT
    function mintDIDNFT(address token, uint256 grade) public {
        // 等级只能是1或2
        require(grade == 1 || grade == 2, "grade error");
        // 判断token是否可以支付的
        ShapeDIDNFT memory _shapeDIDNFTs = payDIDNFT[token];
        require(_shapeDIDNFTs.status == 2, "token not exist or not open");
        // 开始转账
        uint256 _value = grade == 1 ? _shapeDIDNFTs.price1 : _shapeDIDNFTs.price2;
        TransferHelper.safeTransferFrom(token, msg.sender, leader, _value);

        // 铸造DIDNFT
        IETEDIDNFT(eteDIDNFT).mintDIDNFT(msg.sender, grade);
    }

    // 使用代币铸造水晶
    function mintCrystals(address token, uint256 amount) public {
        require(amount > 0, "amount error");
        // 判断token是否可以支付的
        ShapeCrystal memory _shapeCrystal = payCrystal[token];
        require(_shapeCrystal.status == 2, "token not exist or not open");
        // 计算需要支付的价格
        uint256 _value = amount.mul(_shapeCrystal.price);
        // 开始转账
        TransferHelper.safeTransferFrom(token, msg.sender, leader, _value);

        // 铸造水晶
        IETEDIDNFT(eteDIDNFT).mintCrystals(msg.sender, _value);
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }



}