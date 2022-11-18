/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

interface BEP20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface NftContract {
    function toMint(address to_) external returns (uint256);

    function gramNumber() external returns (uint256);
}

interface PancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract Route {
    using SafeMath for uint256;
    address private _usdtAddress = 0x9C611e2df859032a0fB4911074c4Feac84aA38DF;
    address private _tslgdAddress = 0xA5564d9BA132809D0E77486Cfd5B1C0ccF9D595E;
    address private _pancakeRouterAddress =
        0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // USDT合约
    BEP20 usdtContract = BEP20(_usdtAddress);
    // TSLGD合约
    BEP20 tslgdContract = BEP20(_tslgdAddress);
    // 薄饼合约
    PancakeRouter pancakeRouterContract = PancakeRouter(_pancakeRouterAddress);
    // 拥有者
    address public owner;
    mapping(address => bool) public mobilityMappingAddress;
    mapping(address => uint256) public mobilityMappingAddressNum;
    address[] private mobilityArrayAddress;

    modifier onlyOwner() {
        require(owner == msg.sender, "Route: Caller is not owner");
        _;
    }
    // 白名单
    mapping(address => bool) public whiteAddress;
    modifier onlyWhiteAddress() {
        require(whiteAddress[msg.sender], "Route: Caller is not white");
        _;
    }
    // 收款地址
    address public collectionAddress;
    // 支持的代币
    mapping(address => bool) public buyTokenContracts;
    // 黄金价格
    uint256 public goldUsdt;

    // 上级地址
    mapping(address => address) public team;
    // 顶级
    address public lord;
    // 是否已购买黄金
    mapping(address => bool) public whetherBuyGold;

    // 购买事件
    event BuyGold(
        address indexed contractAddress,
        address indexed owner,
        address indexed superior,
        uint256 tokenid,
        uint256 usdtNumber,
        uint256 tslgdNumber
    );

    constructor(address _collectionAddress, address _lord) {
        lord = _lord;
        team[_lord] = _lord;
        whetherBuyGold[_lord] = true;
        owner = msg.sender;
        whiteAddress[msg.sender] = true;
        collectionAddress = _collectionAddress;
        goldUsdt = 1 * 10**18;
    }

    // 修改收款地址
    function setCollectionAddress(address _address)
        public
        onlyOwner
        returns (bool)
    {
        collectionAddress = _address;
        return true;
    }

    function getMobilityArrayAddressLength() public view returns (uint256) {
        return mobilityArrayAddress.length;
    }

    function getMobilityArrayAddress(uint256 i) public view returns (address) {
        return mobilityArrayAddress[i];
    }

    // 修改管理员地址
    function setOwner(address _address) public onlyOwner returns (bool) {
        owner = _address;
        return true;
    }

    // 修改合约白名单
    function setWhiteAddress(address[] memory _address, bool _state)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            whiteAddress[_address[i]] = _state;
        }
        return true;
    }

    // 设定支持的币种
    function setBuyTokenContracts(address _address, bool _state)
        public
        onlyOwner
        returns (bool)
    {
        buyTokenContracts[_address] = _state;
        return true;
    }

    // 购买黄金
    function buy(address _address, address _superior) public returns (bool) {
        // 必须绑定上级
        if (team[msg.sender] == address(0)) {
            bindParent(msg.sender, _superior);
        }
        // 必须是可交易的合约
        require(
            buyTokenContracts[_address],
            "Route: This token purchase is not supported"
        );
        // NFT合约
        NftContract nftContract = NftContract(_address);
        // 克数
        uint256 gramNumber = nftContract.gramNumber();
        // 获取NFT价格
        uint256 totalUsdt = goldUsdt.mul(gramNumber);
        if (totalUsdt == 0) {
            totalUsdt = 1 * 10**18;
        }
        // 消耗USDT数量
        uint256 useUsdt = totalUsdt.div(2);
        // 消耗TSLDG数量
        uint256 useTslgd = usdtToToken(totalUsdt.sub(useUsdt), _tslgdAddress);
        // 扣除USDT
        usdtContract.transferFrom(
            msg.sender,
            address(collectionAddress),
            useUsdt
        );
        // 扣除TSLDG
        tslgdContract.transferFrom(
            msg.sender,
            address(collectionAddress),
            useTslgd
        );
        uint256 tokenid = nftContract.toMint(msg.sender);
        whetherBuyGold[msg.sender] = true;
        // 发布购买事件 NFT合约地址 所属人 tokenid
        emit BuyGold(
            _address,
            msg.sender,
            _superior,
            tokenid,
            useUsdt,
            useTslgd
        );
        if (!mobilityMappingAddress[_address]) {
            mobilityArrayAddress.push(_address);
            mobilityMappingAddress[_address] = true;
            mobilityMappingAddressNum[_address] = mobilityMappingAddressNum[
                _address
            ].add(gramNumber);
        }
        return true;
    }

    // USDT转换代币
    function usdtToToken(uint256 _amount, address _token)
        public
        view
        returns (uint256)
    {
        address[] memory paths = new address[](2);
        paths[0] = _usdtAddress;
        paths[1] = _token;
        uint256[] memory amounts = pancakeRouterContract.getAmountsOut(
            _amount,
            paths
        );
        return amounts[1];
    }

    function bindParent(address _from, address _to) internal returns (bool) {
        require(
            whetherBuyGold[_to],
            "Team: Address changed but NFT was not purchased"
        );
        require(
            selTeam(_from, _to),
            "Team: Failed to bind parent-child relationship"
        );
        team[_from] = _to;
        return true;
    }

    function selTeam(address from_, address to_) internal returns (bool) {
        if (team[to_] == address(0)) {
            return false;
        } else {
            if (team[to_] == to_) {
                return true;
            } else {
                if (team[to_] == from_) {
                    return false;
                } else {
                    return selTeam(from_, team[to_]);
                }
            }
        }
    }
}