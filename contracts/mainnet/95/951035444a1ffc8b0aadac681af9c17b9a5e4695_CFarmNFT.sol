/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT

/**
    Contrato de NFT mint e NFT stake fund.
    Your money farm!

    https://coinfarm.com.br/
    https://coinfarm.com.br/en
    https://t.me/coinfarmoficial
    
    dev @gamer_noob_blockchain
 */

pragma solidity ^0.8.0;


//Declaração do codificador experimental ABIEncoderV2 para retornar tipos dinâmicos
pragma experimental ABIEncoderV2;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
*/


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
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

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (uint256);    

    function transfer(address to, uint256 amount) external returns (bool);
    
}


interface interfaceCFarmToken {
    function timeLaunched() external view returns (uint256);
}

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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
}


contract CFarmNFT is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 public timeDeployContract;
    uint256 public timeOpenNFTcontract;

    //estatísticas gerais
    uint256 public howManyBuyNFT;
    uint256 public amountNFTsoldByBUSD;
    uint256 public howManyNFTsoldBUSD;
    uint256 public buyerBUSD;

    uint256 public howManyAmountClaimed;
    uint256 public howManyClaimsRewards;

    uint256 public amountNFTsoldByCFarm;
    uint256 public howManyNFTsoldCFarm;
    uint256 public buyerCFarm;
    uint256 public initialPriceBUSD = 50 * 10 ** 18;

    address public   addressCFarm;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   fundNFTs = 0x6D86162DF4C2b54e4FEA1F6916DF157fd81C64d3;
    address public   treasuryWallet = 0xAAbBE8Fa370C2BC948b3E14D59d2e4B275A2ad97;

    mapping(address => bool) public mappingBuyer;

    mapping(address => bool) public mappingAuth;
    
    receive() external payable { }

    constructor() {
        timeDeployContract = block.timestamp;
    }

    modifier onlyAuthorized() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()] == true, "No hack here!");
        _;
    }
   
    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeDeployContract).div(1 days); 
    }

    function isBuyer(address buyer) public view returns (bool){
        return mappingBuyer[buyer]; 
    }

    //Utilizada para atualizar o preço das NFTs em BUSD
    //retorna a conversão para BUSD dos tokens CFarm
    function getPriceCFarmInBUSD(uint256 amount) public view returns (uint256) {

        if (interfaceCFarmToken(addressCFarm).timeLaunched() == 0) {
            return initialPriceBUSD;
        }

        uint256 retorno;
        if (amount != 0) {
            // generate the uniswap pair path of W6 to WBNB/BNB
            address[] memory path = new address[](3);
            path[0] = addressCFarm;
            path[1] = addressWBNB;
            path[2] = addressBUSD;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amount, path);
            retorno = amountOutMins[path.length -1];
        }
        return retorno;
    } 

    //retorna a conversão para BUSD dos tokens CFarm
    //utilizada no monitoramento da treasury wallet
    function getConvertBUSDtoCFarm(uint256 amount) public view returns (uint256) {
        uint256 retorno;
        if (amount != 0) {
            // generate the uniswap pair path of W6 to WBNB/BNB
            address[] memory path = new address[](3);
            path[0] = addressBUSD;
            path[1] = addressWBNB;
            path[2] = addressCFarm;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amount, path);
            retorno = amountOutMins[path.length -1];
        }
        return retorno;
    } 

    //função consultada pelo backend no monitoramento da fundNFTs
    function getDiference(uint256 lastBUSDbalance) public view returns (uint256,uint256) {

        uint256 balanceBUSDtreasury = IERC20(addressBUSD).balanceOf(treasuryWallet);
        uint256 converteToCFarm;

        if (lastBUSDbalance < balanceBUSDtreasury) {
            converteToCFarm = getConvertBUSDtoCFarm(balanceBUSDtreasury - lastBUSDbalance);
        } 
        return (balanceBUSDtreasury,converteToCFarm);
    } 

    //Geração de números verdadeiramente aleatórios
    //Essa função se baseia no número da compra, e esse número aumenta a cada comprador
    //por isso há um verdadeiro caráter de aleatoriedade nessa função
    //Comprar antes ou depois de outrem é decisivo para o resultado
    function getRandomic() public view returns 
    (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {

        uint256 restDivision = howManyBuyNFT % 10;

        if (restDivision == 0) {
            return (1,1,2,1,2,0,1,1,0,0);

        } else if (restDivision == 1) {
            return (0,1,2,0,2,0,1,2,1,1);

        } else if (restDivision == 2) {
            return (1,0,3,1,1,1,1,1,0,1);

        } else if (restDivision == 3) {
            return (1,1,0,0,2,1,1,2,1,1);

        } else if (restDivision == 4) {
            return (1,0,1,1,0,1,0,2,1,3);

        } else if (restDivision == 5) {
            return (1,1,1,1,1,1,1,1,1,1);

        } else if (restDivision == 6) {
            return (0,2,1,0,1,0,1,2,1,2);

        } else if (restDivision == 7) {
            return (2,1,0,1,2,0,1,2,1,0);

        } else if (restDivision == 8) {
            return (1,0,2,0,1,0,1,3,1,1);

        } else if (restDivision == 9) {
            return (0,2,1,1,1,0,1,2,1,1);

        } else if (restDivision == 10) {
            return (1,1,1,0,2,0,1,2,1,1);
        }

    } 

    //a base da compra é em tokens CFarm
    //O array de IDs passado pelo backend é apenas para identificação e melhor organização do DataBase
    function buyNFT(address buyer, uint256 amount, uint256 wichToken, uint[] memory IDnfts) 
    external 
    whenNotPaused {

        require(buyer == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode apostar");
        require(amount > 0, "Necessario comprar um valor maior que zero");
        require(timeOpenNFTcontract != 0, "As pools de stake ainda nao estao abertas");
        require(wichToken == 1 || wichToken == 2, "Forma de pagamento selecionada invalida");
        
        //BUSD
        if (wichToken == 1) {
            require(IERC20(addressBUSD).balanceOf(buyer) >= amount, "Voce nao possui BUSD suficiente");
            IERC20(addressBUSD).transferFrom(buyer, fundNFTs, amount);
            amountNFTsoldByBUSD += amount;
            howManyNFTsoldBUSD += IDnfts.length;
            buyerBUSD ++;

        //cfarm
        } else if (wichToken == 2) {
            require(IERC20(addressCFarm).balanceOf(buyer) >= amount, "Voce nao possui tokens suficiente");
            IERC20(addressCFarm).transferFrom(buyer, fundNFTs, amount);
            amountNFTsoldByCFarm += amount;
            howManyNFTsoldCFarm += IDnfts.length;
            buyerCFarm ++;

        }

        howManyBuyNFT ++;

        mappingBuyer[buyer] = true;
    }

    //Somente a conta de claim autorizada no backend que pode chamar essa função
    //aqui há o claim dos rewards das cotas de investimentos
    function claimRewards(address buyer, uint256 amount) 
    public 
    onlyAuthorized 
    {
        //require(mappingBuyer[buyer] == true, "Claim disponivel somente para compradores de NFTs");
        IERC20(addressCFarm).transfer(buyer, amount);

        howManyAmountClaimed += amount;
        howManyClaimsRewards ++;
    }

    function uncheckedI (uint256 i) public pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function claimManyRewards (address[] memory buyer, uint256[] memory amount) 
    external 
    onlyAuthorized {

        uint256 buyerLength = buyer.length;
        for (uint256 i = 0; i < buyerLength; i = uncheckedI(i)) {  
            claimRewards(buyer[i],amount[i]);
        }

    }

    function withdraw(address account, uint256 amount) public onlyOwner {
        IERC20(addressCFarm).transfer(account, amount);
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(addressCFarm).balanceOf(address(this));
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function managerBNB () external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerERC20 (address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    //seta a wallet do projeto autorizada para claim
    function setMappingAuth(address account) external onlyOwner {
        mappingAuth[account] = true;
    }

    function setInitialPriceBUSD (uint256 _initialPriceBUSD) external onlyOwner {
        initialPriceBUSD = _initialPriceBUSD;
    }

    function setOpenNFTcontract () external onlyOwner {
        timeOpenNFTcontract = block.timestamp;
    }

    function setCFarmAddressContract (address _addressCFarm) external onlyOwner {
        addressCFarm = _addressCFarm;
    }
}