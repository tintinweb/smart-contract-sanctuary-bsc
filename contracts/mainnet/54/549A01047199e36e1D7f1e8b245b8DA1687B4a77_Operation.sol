/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.7;

interface GlodContract{
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
interface NftContract{
    function toMint(address to_) external returns (bool);
    function toMints(address to_,uint256 amount_) external returns (bool);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function toBurn(uint256 tokenId_) external returns (bool);
    function tokenIdType(uint256 tokenId_) external returns (uint256);
    function ownerOf(uint256 tokenId) external view  returns (address);
    function balanceOf(address owner) external view  returns (uint256);
}
interface Nft1155Contract{
    function tomint(address address_,uint256 id_,uint256 amount_,uint256 type_) external returns (bool);
    function toBurn(address address_,uint256 id_,uint256 amount_) external returns (bool);
    function toTransfer(address from_,address to_,uint256 id_,uint256 amount_) external returns (bool);
    function balanceOf(address account, uint256 id) external view  returns (uint256);
    
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
contract Operation{
    address public TeslaModel3Contract = address(0x523D974061C899d0463B4A43A2E3FD32e8C7d876);
    address public TeslaModelyContract = address(0x83593Bf91fAE44D1d4B07ED44bA571683DBd901c); 
    address public TeslaModelxContract = address(0x324e6deeAf77f53BdA7A6f78a5f05e1bE58A149B);
    address public TeslaModelsContract = address(0x483BEc6775864707be04287F0B5eA0ebfA448fae);
    address public TeslaRoadsterContract = address(0x9c67698426E2de66F367F21925333CB29DB113D9);
    address public TeslaSpaceXContract = address(0xB84D475a924e1fBe2E77eAbFBEa9c1055D5a9136);
    address public BoxContract = address(0xB0b76Ab4ebe27E8C7aA1c8F29dfc447EB1efBD24);
    address public OriginationContract = address(0x45dF66B26B324fE3588145CDC53B00b75B99f26b); 
    address public OrdinaryContract = address(0x3072A71384b3637b29505B16B340e3F91318766c);  
    address public TeamContract = address(0x9F61E183F1D741e8aF6c331118dcf0756e79ffBa);    
    address public CollectionAddress = address(0x00);
    address public UsdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address public TslAddress = address(0x5Ef31a3afF9871d47d8397EBd6Aa04215c3D33d9);
    address public swapRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    GlodContract UsdtGlod =  GlodContract(UsdtAddress);
    GlodContract TslGlod =  GlodContract(TslAddress);
    ISwapRouter swap = ISwapRouter(swapRouterAddress);
    address public _owner;
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    uint256 public PriceFeng = 1;
    uint256 public PriceJing = 100;
    uint256 public PriceCard = 1000;
    uint256 public PriceCardVip = 5000;
    mapping(address=>mapping(address=>bool)) public RePurchase;
    mapping(address=>uint256) public RePurchaseQuantity;
    event buyProp(address address_,uint256 proptype_,uint256 amount_,uint256 price_);
    constructor(address CollectionAddress_){
        CollectionAddress = CollectionAddress_;
        _owner = msg.sender;
    }
    function setOwner(address owner_) public Owner returns (bool){
        _owner = owner_;
        return true;
    }
    function setCollectionAddress(address CollectionAddress_) public Owner returns (bool){
        CollectionAddress = CollectionAddress_;
        return true;
    }
    function setPriceBlindBox(uint256 newPrice_ , uint256 type_) public Owner returns (bool){
        if(type_ == 1){
            PriceFeng = newPrice_;
        }else if(type_ == 2){
            PriceJing = newPrice_;
        }else{
            require(false, "Parameter error");
        }
        return true;
    }
    function setPriceCard(uint256 newPrice_ , uint256 type_) public Owner returns (bool){
        if(type_ == 1){
            PriceCard = newPrice_;
        }else if(type_ == 2){
            PriceCardVip = newPrice_;
        }else{
            require(false, "Parameter error");
        }
        return true;
    }
    function UsdtToTsl(uint256 amount_) public view returns(uint256){
        address[] memory paths = new address[](2);
        paths[0] = UsdtAddress;
        paths[1] = TslAddress;
        uint256[] memory amounts = swap.getAmountsOut(amount_,paths);
        return amounts[1];
    }    
    function buyBlindBox(uint256 type_,address superior_,uint256 quantity_) public returns(bool){
        require(quantity_ <= 10, "Parameter error");
        Team Teams = Team(TeamContract);
        if(Teams.team(msg.sender) == address(0x00)){
            Teams.bindingWhite(msg.sender,superior_);
        }
        if(type_ == 1){
            TslGlod.transferFrom(msg.sender,address(CollectionAddress),UsdtToTsl(PriceFeng * quantity_ * 10**UsdtGlod.decimals()));
            emit buyProp(msg.sender,1,quantity_,PriceFeng * quantity_);
        }else if(type_ == 2){
            TslGlod.transferFrom(msg.sender,address(CollectionAddress),UsdtToTsl(PriceJing * quantity_ * 10**UsdtGlod.decimals()));
            emit buyProp(msg.sender,2,quantity_,PriceJing * quantity_);
        }else{
            require(false, "Parameter error");
        }
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        Box.tomint(msg.sender,type_,quantity_,1);
        return true;
    }
    function openBlindBox(uint256 id_,uint256 amount_) public returns(bool){
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        require(amount_ <= 10, "Parameter error");
        require(Box.balanceOf(msg.sender,id_) >= amount_, "Insufficient number of blind boxes");
        for(uint i = 0; i < amount_ ; i++){
            if(id_ == 1){
                uint256 PoweRand = _PoweRand(0,10000,i);
                if(PoweRand <= 2){
                    NftContract Tesla = NftContract(TeslaSpaceXContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 2 && PoweRand <= 5){
                    NftContract Tesla = NftContract(TeslaRoadsterContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure"); 
                }
                if(PoweRand > 5 && PoweRand <= 10){
                    NftContract Tesla = NftContract(TeslaModelsContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 10 && PoweRand <= 100){
                    NftContract Tesla = NftContract(TeslaModelxContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 100 && PoweRand <= 500){
                    NftContract Tesla = NftContract(TeslaModelyContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 500){
                    NftContract Tesla = NftContract(TeslaModel3Contract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
            }else if(id_ == 2){
                uint256 PoweRand = _PoweRand(0,100,i);
                if(PoweRand <= 2){
                    NftContract Tesla = NftContract(TeslaSpaceXContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 2 && PoweRand <= 7){
                    NftContract Tesla = NftContract(TeslaRoadsterContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 7 && PoweRand <= 15){
                    NftContract Tesla = NftContract(TeslaModelsContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 15 && PoweRand <= 25){
                    NftContract Tesla = NftContract(TeslaModelxContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 25){
                    NftContract Tesla = NftContract(TeslaModelyContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
            }else{
                require(false, "Wrong type of blind box");
            }
        }
        require(Box.toBurn(msg.sender,id_,amount_), "Destroy failed");
        return true;
    }
    /**
    *   买股东卡       ALL
    *   ShareholderContract_         股东卡合约地址   
    *   superior_                   推荐人
    */
    function buyCard(address ShareholderContract_,address superior_) public returns(bool){
        GlodContract Glod =  GlodContract(UsdtAddress);
        Team Teams = Team(TeamContract);
        if(Teams.team(msg.sender) == address(0x00)){
            Teams.bindingWhite(msg.sender,superior_);
        }
        NftContract Shareholder_1 =  NftContract(OrdinaryContract); 
        NftContract Shareholder_2 =  NftContract(OriginationContract); 
        if(ShareholderContract_ == OrdinaryContract){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceCard * 10**Glod.decimals());
            emit buyProp(msg.sender,3,1,PriceCard);
            if(!RePurchase[superior_][msg.sender]){
                if(Shareholder_1.balanceOf(superior_) > 0 || Shareholder_2.balanceOf(superior_) > 0){
                    RePurchaseQuantity[superior_] += 1;
                }
                RePurchase[superior_][msg.sender] = true;
            }
            if(RePurchaseQuantity[superior_] == 5){
                Shareholder_1.toMint(superior_);
            }
            Shareholder_1.toMint(msg.sender);
        }else if(ShareholderContract_ == OriginationContract){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceCardVip * 10**Glod.decimals());
            emit buyProp(msg.sender,4,1,PriceCardVip);
            Shareholder_2.toMint(msg.sender);
        }else{
            require(false, "Parameter error");
        }
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        Box.tomint(msg.sender,1,100,2);
        return true;
    }

    function _PoweRand(uint256 min_,uint256 poor_,uint256 i_) internal view returns(uint256 PoweRand){
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,i_)));
        uint256 rand = random % poor_;
        return (min_ + rand);
    }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}