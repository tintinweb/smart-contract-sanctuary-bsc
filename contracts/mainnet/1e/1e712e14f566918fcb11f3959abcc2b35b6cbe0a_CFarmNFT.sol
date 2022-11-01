/**
 *Submitted for verification at BscScan.com on 2022-11-01
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

/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}


contract CFarmNFT is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 public timeDeployContract;
    uint256 public timeOpenNFTcontract;

    uint256 public initialPriceBUSD = 50 * 10 ** 18;
    uint256 public fees = 1500000000000000;

    uint256 public amountNFTsoldByBUSD;
    uint256 public amountNFTsoldByCFarm;
    uint256 public amountCFarmClaimed;

    address public   addressCFarm =   0x75F01Ca420A1CB86dF6790d2839E8e34B59b7BB1;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   fundNFTs = 0x6D86162DF4C2b54e4FEA1F6916DF157fd81C64d3;
    address public   treasuryWallet = 0xAAbBE8Fa370C2BC948b3E14D59d2e4B275A2ad97;

    address public authAddress = payable(0xf87463BDe0862A3AbDE434070C5472185B1A8E31);
    
    mapping(address => bool) private mappingAuth;

    mapping(address => uint256) public nonces;
    mapping(bytes => bool) private signatureUsed;
    mapping(bytes => infosBuy) private getInfosBySignatureMapping;

    struct infosBuy {
        address buyer;
        uint256 amount;
        uint256 wichToken;
        address contrato;
        uint256 nonce;
        bytes signature;
        bytes32 hash;
    }

    receive() external payable { }

    constructor() {
        timeDeployContract = block.timestamp;
        mappingAuth[authAddress] = true;
    }

    modifier onlyAuthorized() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()] == true, "No hack here!");
        _;
    }

    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeDeployContract).div(1 days); 
    }

    function getInfosBySignature(bytes memory signature) external view returns (infosBuy memory){
        require(_msgSender() == owner() || mappingAuth[_msgSender()] == true, "No consultation allowed");
        return getInfosBySignatureMapping[signature]; 
    }

    //Utilizada para atualizar o preço das NFTs em BUSD
    //retorna a conversão para BUSD dos tokens CFarm
    function getPriceCFarmInBUSD(uint256 amount) public view returns (uint256) {

/*
        if (interfaceCFarmToken(addressCFarm).timeLaunched() == 0) {
            return initialPriceBUSD;
        }
*/
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

    function bytesLength(bytes memory signature) public pure returns (uint256) {
        return signature.length;
    }

    function hashReturn(bytes memory hash) public pure returns (bytes32,bytes32) {
        return (keccak256(abi.encodePacked(hash)),keccak256(hash));
    }

    function ckeckSignatureCrypto(
        address buyer,
        uint256 amount,
        address contrato,
        uint256 nonce, 
        bytes memory signature) private {
        require(getInfosBySignatureMapping[signature].buyer == address(0x0), "Assinatura ja foi usada");

        require(address(this) == contrato, "Contrato invalido");
        require(signature.length == 65, "Comprimento da assinatura nao foi aprovado");
        require(contrato == address(this), "Nao e o contrato");
        require(keccak256(abi.encodePacked(signature)) != 
                keccak256(abi.encodePacked("0x19457468657265756d205369676e6564204d6573736167653a0a3332")), 
                "Tentativa de exploit");

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encodePacked(prefix, 
                keccak256(abi.encodePacked(contrato,buyer,nonce,amount))));

        address recoveredAddress = ECRecovery.recover(hash, signature);
        
        require(_msgSender() == buyer, "No hacking here, no mempool bot here, motherfuck!");
        require(recoveredAddress == authAddress, "A assinatura nao foi autorizada");
        require(nonces[recoveredAddress]++ == nonce, "Nonce ja utilizado");
    }

    function decodeSignature(
        address buyer,
        uint256 amount,
        address contrato,
        uint256 nonce, 
        bytes memory signature) public pure returns 
        (address,uint256,uint256,bytes memory,bytes32,address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encodePacked(prefix, keccak256(abi.encodePacked(contrato,buyer,nonce,amount))));
        address recoveredAddress = ECRecovery.recover(hash, signature);

        return (buyer,amount,nonce,signature,hash,recoveredAddress);
    }

    function buyNFT(
        address buyer,
        uint256 amount, 
        uint256 wichToken,
        address contrato, 
        uint256 nonce, 
        bytes memory signature) 
        external 
        nonReentrant() whenNotPaused() {

        ckeckSignatureCrypto(
            buyer,
            amount,
            contrato, 
            nonce, 
            signature);

        getInfosBySignatureMapping[signature].buyer = msg.sender; 
        getInfosBySignatureMapping[signature].amount = amount; 
        getInfosBySignatureMapping[signature].wichToken = wichToken; 
        getInfosBySignatureMapping[signature].contrato = contrato; 
        getInfosBySignatureMapping[signature].nonce = nonce; 
        getInfosBySignatureMapping[signature].signature = signature; 

        //BUSD
        if (wichToken == 1) {
            require(IERC20(addressBUSD).balanceOf(msg.sender) >= amount, "Voce nao possui BUSD suficiente");
            IERC20(addressBUSD).transferFrom(msg.sender, fundNFTs, amount);
            amountNFTsoldByBUSD += amount;

        //CFarm
        } else if (wichToken == 2) {
            require(IERC20(addressCFarm).balanceOf(msg.sender) >= amount, "Voce nao possui tokens suficiente");
            IERC20(addressCFarm).transferFrom(msg.sender, fundNFTs, amount);
            amountNFTsoldByCFarm += amount;

        }
    }

    //Somente a conta de claim autorizada no backend que pode chamar essa função
    //aqui há o claim dos rewards das cotas de investimentos
    function claimRewards(
        address buyer,
        uint256 amount) external onlyAuthorized nonReentrant() whenNotPaused() {

        IERC20(addressCFarm).transfer(buyer, amount);

        amountCFarmClaimed += amount;
    }

    //clamador solicita o claim, que será processado posteriormente
    function claimFeesRewards(
        address buyer) external payable nonReentrant() whenNotPaused() {

        require(msg.value == fees, "Valor invalido transferido");
        (bool success,) = authAddress.call{value: fees}("");
        require(success, "Falha ao enviar BNB");
    }

    function uncheckedI (uint256 i) public pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function claimManyRewards (address[] memory buyer, uint256[] memory amount) 
    external 
    onlyOwner {

        uint256 buyerLength = buyer.length;
        for (uint256 i = 0; i < buyerLength; i = uncheckedI(i)) {  
            IERC20(addressCFarm).transfer(buyer[i], amount[i]);
        }
    }

    function withdraw(address account, uint256 amount) public onlyOwner {
        IERC20(addressCFarm).transfer(account, amount);
    }

    function managerBNB () external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerERC20 (address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setInitialPriceBUSDandFees (uint256 _initialPriceBUSD, uint256 _fees) external onlyOwner {
        initialPriceBUSD = _initialPriceBUSD;
        fees = _fees;
    }

    //seta a wallet do projeto autorizada
    function setMappingAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
        authAddress = payable(account);
    }

    function setCfarmAddressContract (address _addressCFarm) external onlyOwner {
        addressCFarm = _addressCFarm;
    }
}