/**
 *Submitted for verification at BscScan.com on 2022-10-29
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
interface ILeaderTracker {
    function swapToLeader(address _eteToken) external;
}
// 接口
interface IETEDIDNFT {
    function mintDIDNFT(address user, uint256 amount) external;
    function mintCrystals(address user, uint256 amount) external;
    function burnCrystals(address user, uint256 amount) external;
}
// 接口
interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
}


// 铸造DIDNFT合约
contract MinterDIDNF2 is Ownable {
    using SafeMath for uint256;

    address public USDT;
    address public ETE;
    // 铸造DIDNFT支付的地址数组,[0=ETEOLD_,1=USDT_,2=ETE_]
    address[] public addressDIDNFT;
    // 铸造水晶支付的地址数组
    address[] public addressCrystal;

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
    // 项目方分红合约地址
    address public leaderTracker;
    // nft合约地址
    address public eteDIDNFT;
    // 关系合约地址
    address public linkedin;


    // 铸造DIDNFT事件
    event MintDIDNFT(address token, address user, uint256 grade, uint256 value);
    // 铸造水晶事件
    event MintCrystals(address token, address user, uint256 amount, uint256 value);


    constructor(
        address owner_,
        address leader_,
        address leaderTracker_,
        address eteDIDNFT_,
        address linkedin_,

        address[] memory addressDIDNFT_,
        uint256[] memory addressDIDNFTPrice_,
        address[] memory addressCrystal_,
        uint256[] memory addressCrystalPrice_
        ) Ownable(owner_) {
        leader = leader_;
        leaderTracker = leaderTracker_;
        eteDIDNFT = eteDIDNFT_;
        linkedin = linkedin_;
        require(addressDIDNFT_.length == addressDIDNFTPrice_.length, "price error1");
        require(addressCrystal_.length == addressCrystalPrice_.length, "price error1");

        // [ETEOLD_,USDT_,ETE_]
        addressDIDNFT = addressDIDNFT_;
        // [ETES_,ETE_]
        addressCrystal = addressCrystal_;
        
        // 设置为铸造DIDNFT和铸造水晶
        for(uint256 i0 = 0; i0 < addressDIDNFT.length; i0++) {
            payDIDNFT[addressDIDNFT[i0]] = ShapeDIDNFT({status: 2, price1: addressDIDNFTPrice_[i0], price2: addressDIDNFTPrice_[i0]*2});
        }
        for(uint256 i1 = 0; i1 < addressCrystal.length; i1++) {
            payCrystal[addressCrystal[i1]] = ShapeCrystal({status: 2, price: addressCrystalPrice_[i1]});
        }
        
        USDT = addressDIDNFT[1];
        ETE = addressDIDNFT[2];
        payDIDNFT[ETE].status = 1;
        payCrystal[ETE].status = 1;
    }

    // 添加铸造DIDNFT地址和价格
    function addPayDIDNFT(address token, uint256 price1, uint256 price2) public onlyOwner {
        require(token != address(0), "0 address error");
        require(price1 > 0, "0 price1 error");
        require(price2 > 0, "0 price2 error");
        require(payDIDNFT[token].status == 0, "token exist");
        addressDIDNFT.push(token);
        payDIDNFT[token] = ShapeDIDNFT({status: 2, price1: price1, price2: price2});
    }

    // 添加铸造水晶地址和价格
    function addPayCrystal(address token, uint256 price) public onlyOwner {
        require(token != address(0), "0 address error");
        require(price > 0, "0 price error");
        require(payCrystal[token].status == 0, "token exist");
        addressCrystal.push(token);
        payCrystal[token] = ShapeCrystal({status: 2, price: price});
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

    // 设置项目方分红合约地址
    function setLeaderTracker(address newLeaderTracker) public onlyOwner {
        require(newLeaderTracker != address(0), "zero address error");
        leaderTracker = newLeaderTracker;
    }

    // 设置eteDIDNFT地址
    function setEteDIDNFT(address newEteDIDNFT) public onlyOwner {
        require(newEteDIDNFT != address(0), "zero address error");
        eteDIDNFT = newEteDIDNFT;
    }

    // 设置关系合约地址
    function setLinkedin(address newLinkedin) public onlyOwner {
        require(newLinkedin != address(0), "zero address error");
        linkedin = newLinkedin;
    }

    // 查询DIDNFT铸造的全部币种和可支付状态和价格
    function getAllPayDIDNFT() public view returns(address[] memory tokens, ShapeDIDNFT[] memory shapeDIDNFTs) {
        uint256 len = addressDIDNFT.length;
        tokens = new address[](len);
        shapeDIDNFTs = new ShapeDIDNFT[](len);

        for(uint256 i = 0; i < len; i++) {
            address _token = addressDIDNFT[i];
            tokens[i] = _token;
            shapeDIDNFTs[i] = ShapeDIDNFT({status: payDIDNFT[_token].status, price1: payDIDNFT[_token].price1, price2: payDIDNFT[_token].price2});
        }
    }

    // 查询水晶铸造的全部币种和可支付状态和价格
    function getAllPayCrystal() public view returns(address[] memory tokens, ShapeCrystal[] memory shapeCrystals) {
        uint256 len = addressCrystal.length;
        tokens = new address[](len);
        shapeCrystals = new ShapeCrystal[](len);

        for(uint256 i = 0; i < len; i++) {
            address _token = addressCrystal[i];
            tokens[i] = _token;
            shapeCrystals[i] = ShapeCrystal({status: payCrystal[_token].status, price: payCrystal[_token].price});
        }
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


        // TransferHelper.safeTransferFrom(token, msg.sender, leader, _value);
        _mintDIDNFTSafeTransferFrom(token, msg.sender, leader, _value);

        // 铸造DIDNFT
        IETEDIDNFT(eteDIDNFT).mintDIDNFT(msg.sender, grade);
        emit MintDIDNFT(token, msg.sender, grade, _value);

        // 自动兑换
        try ILeaderTracker(leaderTracker).swapToLeader(ETE) {} catch {}
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
        // TransferHelper.safeTransferFrom(token, msg.sender, leader, _value);
        _mintCrystalsDIDNFTSafeTransferFrom(token, msg.sender, leader, _value);

        // 铸造水晶
        IETEDIDNFT(eteDIDNFT).mintCrystals(msg.sender, amount);
        emit MintCrystals(token, msg.sender, amount, _value);

        // 自动兑换
        try ILeaderTracker(leaderTracker).swapToLeader(ETE) {} catch {}
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // 铸造NFT转账的封装
    function _mintDIDNFTSafeTransferFrom(address token, address from, address to, uint256 value) private {
        if(token == USDT) {
            // 如果是USDT，10%给上级，90%给收币地址。没有上级给收币地址
            uint256 _superAmount = value.mul(10).div(100);
            uint256 _leaderAmount = value.sub(_superAmount);
            address _superAddress = ILinkedin(linkedin).mySuper(from);
            _superAddress = _superAddress == address(0) ? leader : _superAddress;

            TransferHelper.safeTransferFrom(token, from, _superAddress, _superAmount);
            TransferHelper.safeTransferFrom(token, from, to, _leaderAmount);
        }else if(token == ETE) {
            // 如果是ETE(新的)，10%给上级，90%给0地址销毁。没有上级给收币地址
            uint256 _superAmount = value.mul(10).div(100);
            uint256 _burnAmount = value.sub(_superAmount);
            address _superAddress = ILinkedin(linkedin).mySuper(from);
            _superAddress = _superAddress == address(0) ? leader : _superAddress;

            TransferHelper.safeTransferFrom(token, from, _superAddress, _superAmount);
            TransferHelper.safeTransferFrom(token, from, address(0), _burnAmount);
        }else {
            // 正常转账
            TransferHelper.safeTransferFrom(token, from, to, value);
        }
    }

    // 铸造水晶转账的封装
    function _mintCrystalsDIDNFTSafeTransferFrom(address token, address from, address to, uint256 value) private {
        if(token == ETE) {
            // 如果是ETE的话，全部销毁。
            TransferHelper.safeTransferFrom(token, from, address(0), value);
        }else {
            // 其它就正常转账
            TransferHelper.safeTransferFrom(token, from, to, value);
        }
    }


}