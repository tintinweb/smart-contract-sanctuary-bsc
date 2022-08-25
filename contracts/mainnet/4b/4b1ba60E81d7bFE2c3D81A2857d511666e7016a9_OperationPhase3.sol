/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;

interface GlodContract{
    function _tomint(address sender,uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
interface NftContract{
    function toMint_buy(address f_,address to_) external returns (uint256);
    function toMint_synthesis(address to_) external returns (uint256);
    function toMint_give(address to_) external returns (uint256);
    function totalSupply() external view  returns (uint256);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function ownerOf(uint256 tokenid_) external view returns (address);
    function Nftinformation(uint256 tokenid_) external view returns (uint256,uint256);
    function setLastCollectionTime(uint256 tokenid_) external returns (bool);
    function castingOk(uint256 tokenid_) external view returns (bool);
    function setCastingOk(uint256 tokenid_) external returns (bool);   
    function fNumber_(address f_) external view returns (uint256);   
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

contract OperationPhase3{
    //购买USDT合约地址
    address public BuyTokenUsdtContract = address(0x55d398326f99059fF775485246999027B3197955);
    //节点合约地址
    address public SwapNodeContract = address(0x019D6424133cCC2d287e972B9B71D83c1cA989BD);
    //上下级合约
    address public TeamContract = address(0x9F61E183F1D741e8aF6c331118dcf0756e79ffBa); 
    //swap路由合约
    address public swapRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    ISwapRouter swap = ISwapRouter(swapRouterAddress);

    address public _owner;//管理员
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    //购买USDT价格
    uint256 public BuyTokenUsdtnumber = 1 * 10**16;

    //支持的代币
    mapping(address => bool) public BuyTokenContracts;

    //收款地址
    address public CollectionAddress;

    //合成节点卡
    event MintSynthesis(address indexed Contract,address indexed owner,uint256 tokenid,uint256 blocknumber);
    //购买节点卡
    event MintBuys(address indexed Contract,address indexed owner,uint256 tokenid,uint256 blocknumber);
    //赠送节点卡
    event MintGives(address indexed Contract,address indexed owner,uint256 tokenid,uint256 blocknumber);

    constructor(address CollectionAddress_){
        _owner = msg.sender;
        CollectionAddress = CollectionAddress_;
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
    //设定支持的币种
    function setBuyTokenContracts(address BuyTokenContracts_,bool state_) 
        public 
        Owner 
        returns (bool)
        {
            BuyTokenContracts[BuyTokenContracts_] = state_;
            return true;
        }
    //合成TSLSwapNodeCards
    function Mint_synthesis(address[] memory teslaContract_,uint256[] memory tokenid_) 
        public 
        returns(bool)
        {
            Team Teams = Team(TeamContract);
            require(Teams.team(msg.sender) != address(0x00), "No composition permission");
            require(teslaContract_.length == 5, "Contract quantity error");
            require(tokenid_.length == 5, "Wrong number of tokenids");
            for(uint i = 0 ; i < 5 ; i++){
                NftContract Tesla = NftContract(teslaContract_[i]);
                Tesla.toTransfer(msg.sender,address(SwapNodeContract),tokenid_[i]);
            }
            NftContract SwapNodeCards = NftContract(SwapNodeContract);
            uint256 tokenid = SwapNodeCards.toMint_synthesis(msg.sender);
            //发布合成事件 路由合约地址 合成人地址 合成的tokenid 区块高度
            emit MintSynthesis(address(this),address(msg.sender),tokenid, block.number);
            return true;
        }
    //购买TSLSwapNodeCards
    function Mint_buy(address TokenContracts_) 
        public 
        returns(bool)
        {
            Team Teams = Team(TeamContract);
            address f = Teams.team(msg.sender);
            require(address(f) != address(0x00), "No composition permission");
            if(TokenContracts_ == BuyTokenUsdtContract){
                GlodContract BuyToken = GlodContract(BuyTokenUsdtContract);
                BuyToken.transferFrom(msg.sender,address(CollectionAddress),BuyTokenUsdtnumber);
            }else{
                require(BuyTokenContracts[TokenContracts_], "This token purchase is not supported");  
                GlodContract BuyToken = GlodContract(TokenContracts_);
                BuyToken.transferFrom(msg.sender,address(CollectionAddress),UsdtToToken(BuyTokenUsdtnumber,TokenContracts_));
            }
            NftContract SwapNodeCards = NftContract(SwapNodeContract);
            uint256 tokenid = SwapNodeCards.toMint_buy(f,msg.sender);
            //发布购买事件 路由合约地址 合成人地址 合成的tokenid 区块高度
            emit MintBuys(address(this),address(msg.sender),tokenid, block.number);
            //查询是否推荐三人;
            if(SwapNodeCards.fNumber_(address(f)) == 3){
                uint256 tokenidgive = SwapNodeCards.toMint_give(f);
                emit MintGives(address(this),address(msg.sender),tokenidgive, block.number);
            }
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