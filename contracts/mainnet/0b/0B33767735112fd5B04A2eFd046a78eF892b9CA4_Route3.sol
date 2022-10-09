/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;

interface GlodContract{
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
interface NftContract{
    function toMint(address to_) external returns (uint256);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function ownerOf(uint256 tokenId) external returns (address owner);
}
interface Team{
    function team(address from_) external returns (address);
    function bindingWhite(address from_ , address to_) external returns (bool);
}

interface ISwapRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract Route3{
    //购买USDT合约地址
    address public BuyTokenUsdtContract = address(0x55d398326f99059fF775485246999027B3197955);
    //上下级合约
    address public TeamContract = address(0xd72bfddE950F6BDC0eA3a311F287c432D7804d11); 
    Team Teams = Team(TeamContract);
    //火箭合约地址
    address public RocketContract = address(0x0Ac2bd6D2D42425dA512D635482920479aE0FB0D);
    NftContract Rocket = NftContract(RocketContract);
    //超级火箭合约地址
    address public RocketsuperContract = address(0xA329B04B0159eb7018aa259A65E9fc2C57FDcD96);
    NftContract Rocketsuper = NftContract(RocketsuperContract);
    
    //swap路由合约
    address public swapRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    ISwapRouter swap = ISwapRouter(swapRouterAddress);
    address public _owner;//管理员
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    //合约白名单
    mapping(address=>bool) private _WhiteListContract;
    modifier WhiteList {   //合约白名单
        require(_WhiteListContract[msg.sender]);
        _;
    }
    //购买USDT价格
    uint256 public BuyTokenUsdtnumber = 200 * 10**18;
    //支持的代币
    mapping(address => bool) public BuyTokenContracts;
    //排队人
    mapping(uint256 => address) public Queuee;
    //是否出局
    mapping(uint256 => bool) public Outing;

    //收款地址
    address public CollectionAddress;
    //购买
    event BuyRocket(address indexed Contract,address indexed owner,address indexed superior,uint256 tokenid,uint256 blocknumber);
    //排队
    event LineUp(address indexed Contract,address indexed owner,uint256 tokenid);
    //取消排队
    event LineUpOut(address indexed Contract,address indexed owner,uint256 tokenid);
    //合成超级火箭
    event BuyRocketsuper(address indexed Contract,address indexed owner,uint256[] tokenidS,uint256 tokenid,uint256 blocknumber);
    constructor(address CollectionAddress_){
        _owner = msg.sender;
        _WhiteListContract[msg.sender] = true;
        CollectionAddress = CollectionAddress_;
    }
    //修改收款地址
    function setCollectionAddress(address CollectionAddress_) public Owner returns (bool){
        CollectionAddress = CollectionAddress_;
        return true;
    }
    //修改USDT代币价格
    function setBuyTokenUsdtnumber(uint256 BuyTokenUsdtnumber_) 
        public 
        Owner 
        returns (bool)
        {
            BuyTokenUsdtnumber = BuyTokenUsdtnumber_;
            return true;
        }
    //修改管理员地址
    function setOwner(address owner_) 
        public 
        Owner 
        returns (bool)
        {
            _owner = owner_;
            return true;
        }
    /**
    * 修改合约白名单
    */
    function setWhiteListContract(address WhiteListContract_,bool state_) 
        public 
        Owner 
        returns (bool)
        {
            _WhiteListContract[WhiteListContract_] = state_;
            return true;
        }
    /**
    * 地址是否在白名单中
    */
    function WhiteListContract(address address_) public view returns (bool){
        return _WhiteListContract[address_];
    }
    //设定支持的币种
    function setBuyTokenContracts(address BuyTokenContracts_,bool state_) 
        public 
        Owner 
        returns (bool)
        {
            BuyTokenContracts[BuyTokenContracts_] = state_;
            return true;
        }
    
    //购买火箭
    function buy(address TokenContracts_,address superior_) 
        public 
        returns(bool)
        {
            if(Teams.team(msg.sender) == address(0x00)){
                Teams.bindingWhite(msg.sender,superior_);
            }
            if(TokenContracts_ == BuyTokenUsdtContract){
                GlodContract BuyToken = GlodContract(BuyTokenUsdtContract);
                BuyToken.transferFrom(msg.sender,address(CollectionAddress),BuyTokenUsdtnumber);
            }else{
                require(BuyTokenContracts[TokenContracts_], "This token purchase is not supported");  
                GlodContract BuyToken = GlodContract(TokenContracts_);
                BuyToken.transferFrom(msg.sender,address(CollectionAddress),UsdtToToken(BuyTokenUsdtnumber,TokenContracts_));
            }
            uint256 tokenid = Rocket.toMint(msg.sender);
            //发布购买事件 路由合约地址 合成人地址 合成的tokenid 区块高度
            emit BuyRocket(address(this),address(msg.sender),address(superior_),tokenid,block.number);
            return true;
        }
    //参与排队
    function lineup(uint256 tokenid_) 
        public 
        returns(bool)
        {
            require(Rocket.ownerOf(tokenid_) == msg.sender, "Not your tokenid"); 
            require(Queuee[tokenid_] == address(0x00), "Do not queue repeatedly");  
            Rocket.toTransfer(msg.sender,address(RocketContract),tokenid_);
            Queuee[tokenid_] = msg.sender;
            emit LineUp(address(this),address(msg.sender),tokenid_);
            return true;
        }
    //退出排队
    function lineupOut(uint256 tokenid_) 
        public 
        returns(bool)
        {
            require(Queuee[tokenid_] == msg.sender, "It's not your line");  
            require(Outing[tokenid_] == false, "tokenid Out");  
            Rocket.toTransfer(address(RocketContract),msg.sender,tokenid_);
            emit LineUpOut(address(this),address(msg.sender),tokenid_);
            return true;
        }
    //出局
    function Out(uint256 tokenid_,bool state_)
        public
        WhiteList
        returns(bool)
        {
            Outing[tokenid_] = state_;
            Rocket.toTransfer(address(RocketContract),address(0x00),tokenid_);
            return true;
        }
    //合成超级火箭
    function Synthesis(uint256[] memory tokenids_) 
        public 
        returns(bool)
        {
            require(tokenids_.length == 5, "Wrong number of tokenids");
            for(uint i = 0 ; i < 5 ; i++){
                Rocket.toTransfer(msg.sender,address(RocketsuperContract),tokenids_[i]);
            }
            uint256 tokenid = Rocketsuper.toMint(msg.sender);
            //发布购买事件 路由合约地址 合成人地址 合成的tokenid 区块高度
            emit BuyRocketsuper(address(this),address(msg.sender),tokenids_,tokenid,block.number);
            return true;
        }
    //usdt转换代币
    function UsdtToToken(uint256 amount_,address token_) public view returns(uint256){
        address[] memory paths = new address[](2);
        paths[0] = BuyTokenUsdtContract;
        paths[1] = token_;
        uint256[] memory amounts = swap.getAmountsOut(amount_,paths);
        return amounts[1];
    } 
    function _PoweRand(uint256 min_,uint256 poor_,uint256 i_) 
        internal 
        view 
        returns(uint256 PoweRand)
        {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,i_)));
            uint256 rand = random % poor_;
            return (min_ + rand);
        }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) 
        external 
        pure 
        returns(bytes4)
        {
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        }
}