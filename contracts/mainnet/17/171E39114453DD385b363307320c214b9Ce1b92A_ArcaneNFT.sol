/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * SPDX-License-Identifier: MIT
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */
pragma solidity ^0.8.16; 

import "./SafeMath.sol"; // Importa SafeMath
import "./Ownable.sol"; // Importa Owner
import "./ERC1155URIStorage.sol"; // Importa o ERC1155
import "./StakingRewards.sol";
import "./ReentrancyGuard.sol";
import "./LibraryStruct.sol";
import "./GenerateRand.sol";
import "./DividendsNFT.sol";
import "./StringNFT.sol";


interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract ArcaneNFT is ERC1155URIStorage, Ownable, StakeSystem, isStone, ReentrancyGuard {
    using SafeMath for uint256; // SafeMath para uint256
    using NFTStruct for NFTStruct.CreateNFT; // Estrutura NFT
    using NFTStruct for NFTStruct.CountNFT; // EStrutura ID 
    /*=== Mapping ===*/
    mapping (uint256 => NFTStruct.CreateNFT) public createNFT; // Mapeamento das NFTs
    /*=== Address ===*/
    IBEP20 public token; // Endereço BEP20
    Random public randons; // Endereço RandMod
    DividendsPaying public dividends; // Endereço Dividendos
    address private receiveAddress;
    address private burnAddress = 0x000000000000000000000000000000000000dEaD;
    /*=== Uints ===*/
    uint256 public counterNFT; // Contador NFT
    uint256 private feeBNB; // Taxa em BNB
    uint256 public totalValueLocked; // Valor total em Stake
    uint256 public totalLiquidity; // Liquidez total na Pool
    uint256 private feeTax; // Taxa em ARC
    uint256 public totalFee; // Taxas Arrecadadas
    uint256 public timeOne = 1900000; //  21 Dias
    uint256 public timeTwo = 3100000; // 35 Dias
    /*=== Booleano ===*/
    bool private activeStake; // Ativa ou Desativa o Stake
    /*=== Constructor ===*/
    constructor(IBEP20 _token, uint256 _feeBNB) ERC1155("") {
        token = _token; // Define Endereço BEP20
        feeBNB = _feeBNB; // Define Taxa BNB
        randons = new Random(); // Define Endereço de Random
        dividends = new DividendsPaying(); // Define Endereço de Dividendos
    }
    /*=== Event ===*/
    event NewMint(address indexed from, address indexed to, uint256 indexed id);
    event NewStake(address indexed sender, uint256 indexed sAmount, uint256 indexed bAmount);
    event UriNFT(uint256 indexed id, string indexed newUri);
    /*=== Receive ===*/
    receive() external payable {}
    /*=== Modifier ===*/
    modifier decompose(uint256 id, address account) {
        require(vestingTime(id) == 0, "Tempo de Bloqueio precisa estar Zerado");
        NFTStruct.CreateNFT storage nft = createNFT[id];
         require(nft.userAdmin == account, "Voce precisa ser dono dessa NFT");
         if(nft.isShareholder) {
             revert("Cotista nao pode Desfazer NFT");
         }
        if(nft.isPreSale || nft.isPrivateSale) {
            revert("Voce nao pode desfazer essa NFT");
        }
        if(nft.isStaking) {
            revert("Precisa sair do Stake para Decompor essa NFT");
        }
        _;
    }
    /*=== Private/Internal ===*/
    function generateID() internal returns(uint256) {
        return counterNFT += 1; // Gera um novo ID 
    }
    function generateBlockTime(uint256 boost) internal view returns(uint256) {
        if(boost <= 40) {
            return timeOne;
        }
        else {
            return timeTwo;
        }
    }
    function vestingTime(uint256 id) public view returns(uint256) {
        NFTStruct.CreateNFT storage nft = createNFT[id];
        uint256 currentTimes = block.timestamp;
        uint256 endBlock = nft.endVesting;
        if(currentTimes >= endBlock) {
            return 0;
        }
        else {
            return endBlock - currentTimes;
        }
    }
    function randomOwner() public view returns(address) {
        return randons.owner();
    }
    function dividendsOwner() public view returns(address) {
        return dividends.owner();
    }
    function withdrawableDividendOf(address sender) public view returns(uint256) {
        return dividends.withdrawableDividendOf(sender);
    }
    function accumulativeDividendOf(address sender) public view returns(uint256) {
        return dividends.accumulativeDividendOf(sender);
    }
    function fetchMyNfts(address account) public view returns(NFTStruct.CreateNFT[] memory) {
        // Pega o Ultimo NFT mintado
        uint256 totalNft = counterNFT;
        // Cria o sistema de Iteração
        uint256 itemCount = 0;
        // Pega o Ultimo ID do _msgSender()
        uint256 currentIndex = 0;
        // Cria uma Iteração para o LOOP FOR pegando todas as Ids do OwnerNFT
        for (uint i = 0; i < totalNft; i++) {
            if (createNFT[i + 1].userAdmin == account) {
            itemCount += 1;
            }
        }
        // Gera uma Nova Iteração com os IDs já definidos de cada _msgSender()
        NFTStruct.CreateNFT[] memory items = new NFTStruct.CreateNFT[](itemCount);
        for (uint i = 0; i < totalNft; i++) {
            if (createNFT[i + 1].userAdmin == account) {
            uint currentId = i + 1;
            NFTStruct.CreateNFT storage currentItem = createNFT[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
            }
        }
        return items;
    }
    function stringCallData(uint256 id, string memory nftUri) private  {
        _setURI(id, nftUri); // Armazena URI
        emit UriNFT(id, nftUri); // Emite um Evento
    }
    // function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
    // bytes memory b1 = bytes(s1);
    // bytes memory b2 = bytes(s2);
    // uint256 l1 = b1.length;
    // if (l1 != b2.length) return false;
    // for (uint256 i=0; i<l1; i++) {
    //     if (b1[i] != b2[i]) return false;
    // }
    // return true;
    // }
    /*=== External/Public ===*/
    function castingNFT(uint256 tAmount, uint256 idStone) external payable nonReentrant {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        require(activeStake, "Stake precisa ser ativado");
        require(tAmount > 0, "Amount precisa ser maior do que Zero");
        totalValueLocked += tAmount;
        uint256 initialTime = block.timestamp; 
        uint256 newID = generateID(); 
        uint256 autoBoost = randons.generateRandMod();
        NFTStruct.CreateNFT storage nft = createNFT[newID];
        nft.userAdmin = payable(_msgSender()); 
        nft.idNFT = newID; 
        nft.initialValue = tAmount;
        nft.percentBoost = autoBoost; 
        nft.valueBoost = (tAmount.mul(autoBoost).div(100)).add(tAmount);
        nft.startVesting = initialTime;
        nft.endVesting = initialTime.add(generateBlockTime(autoBoost));
        nft.isUser = true;
        IBEP20(token).transferFrom(_msgSender(), address(this), tAmount);
        require(idStone == 1 || idStone == 2 || idStone == 3 || idStone == 3 || idStone == 4,"Precisa definir String");
        if (idStone == 1){
            nft.nameNFT = "Fire Stone";
            stringCallData(newID, fireStone);
        }
        if (idStone == 2){
            nft.nameNFT = "Water Stone";
            stringCallData(newID, waterStone);
        }
        if (idStone == 3){
            nft.nameNFT = "Soul Stone";
            stringCallData(newID, soulStone);
        }
        if (idStone == 4){
            nft.nameNFT = "Life Stone";
            stringCallData(newID, lifeStone);
        }
        _mint(_msgSender(), newID, 1, "" );
        emit NewMint(address(0), _msgSender(), newID); // emite um evento
    }
    function startStake(uint256 id) external payable updateReward(_msgSender()) nonReentrant{
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        require(activeStake, "Stake precisa ser ativado");
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            bool isTrue = nft.isStaking;
            uint256 sAmount = nft.initialValue;
            uint256 bAmount = nft.valueBoost;
            require(!isTrue, "NFT Ja esta em Staking");
            nft.isStaking = true;
            balanceUser[_msgSender()] += bAmount;
            totalSupplyRewards += sAmount;
            emit NewStake(_msgSender(), sAmount, bAmount);
        }
        else {
            revert("Voce precisa ser Dono da NFT");
        }
    }
    function stopStake(uint256 id) external payable updateReward(_msgSender()) nonReentrant{
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            bool isTrue = nft.isStaking;
            uint256 sAmount = nft.initialValue;
            uint256 bAmount = nft.valueBoost;
            require(isTrue, "NFT nao esta em Staking");
            nft.isStaking = false;
            balanceUser[_msgSender()] -= bAmount;
            totalSupplyRewards -= sAmount;
        }
        else {
            revert("Voce precisa ser Dono da NFT");
        }
    }
    function takeMyRewards() external payable updateReward(_msgSender())  nonReentrant{
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        require(harvestUser() == 0, "Tempo de Colheita nao liberado");
        blockHarvest();
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            uint256 fee = reward.mul(feeTax).div(100);
            reward = reward.sub(fee);
            totalFee += fee;
            totalLiquidity -= reward;
            rewards[_msgSender()] = 0;
            IBEP20(token).transfer(_msgSender(), reward);
        }
        else {
            revert("ARC:Voce nao Possui Saldo de Recompensa");
        }
    }
    function decomposeNFT(uint256 id) external payable decompose(id, _msgSender()) nonReentrant{
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        NFTStruct.CreateNFT storage nft = createNFT[id];        
        nft.userAdmin = payable(address(0)); 
        nft.percentBoost = 0; 
        nft.valueBoost = 0;
        uint256 value = nft.initialValue;
        totalValueLocked -= value;
        IBEP20(token).transfer(_msgSender(), value);
        nft.initialValue = 0;
        _safeTransferFrom(_msgSender(), burnAddress, id, 1, "");
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual  {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            if(nft.isStaking) revert("Precisa sair do Stake");
            nft.userAdmin = payable(to);
            if(nft.isShareholder) {
                dividends.newBalance(from, to, nft.valueBoost);
            }
            _safeTransferFrom(from, to, id, amount, "");
        }
        else {
            revert("Precisa ser o Dono dessa NFT");
        }
    }
    function getBNBShareHolder() public {
        dividends.withdrawMyReward(_msgSender());
    }
    /*=== Administrativo ===*/
    function ownerNFT(address recipient, uint256 idStone, uint256 tAmount, uint256 endBlocks, uint256 boost, bool presale, bool privatesale, bool shareholder) external onlyOwner {
        uint256 newID = generateID();
        uint256 autoBoost = boost;
        uint256 initialTime = block.timestamp;
        NFTStruct.CreateNFT storage nft = createNFT[newID];
        nft.userAdmin = payable(recipient); 
        nft.idNFT = newID;
        nft.initialValue = tAmount; 
        nft.percentBoost = autoBoost; 
        nft.valueBoost = (tAmount.mul(autoBoost).div(100)).add(tAmount);
        nft.startVesting = initialTime;
        nft.endVesting = initialTime + endBlocks;
        nft.isUser = true;
        nft.isPreSale = presale;
        nft.isPrivateSale = privatesale;
        nft.isShareholder = shareholder;
        if(shareholder) {
            dividends.addBalance(recipient, nft.valueBoost);
        }
        require(idStone == 1 || idStone == 2 || idStone == 3 || idStone == 3 || idStone == 4,"Precisa definir String");
        if (idStone == 1){
            nft.nameNFT = "Fire Stone";
            stringCallData(newID, fireStone);
        }
        if (idStone == 2){
            nft.nameNFT = "Water Stone";
            stringCallData(newID, waterStone);
        }
        if (idStone == 3){
            nft.nameNFT = "Soul Stone";
            stringCallData(newID, soulStone);
        }
        if (idStone == 4){
            nft.nameNFT = "Life Stone";
            stringCallData(newID, lifeStone);
        }
        _mint(recipient, newID, 1, "" );
    }
    function manualDecompose(uint256 percent, uint256 id) external onlyOwner {
        NFTStruct.CreateNFT storage nft = createNFT[id];    
        require(nft.isPreSale || nft.isPrivateSale, "Essa NFT nao esta em private ou pre-sale");    
        uint256 oldValue = nft.initialValue;
        uint256 newValue = nft.initialValue.mul(percent).div(100);
        nft.initialValue = oldValue.sub(newValue);
        nft.valueBoost -= newValue;
        totalValueLocked -= newValue;
        IBEP20(token).transfer(_msgSender(), newValue);
    }
    function setUri(uint256 tokenId, string calldata tokenURI, string calldata idStone) external onlyOwner {
        NFTStruct.CreateNFT storage nft = createNFT[tokenId];
        _setURI(tokenId, tokenURI);
        nft.nameNFT = idStone;
    }
    function setFeeBNB(uint256 _feeBNB) external onlyOwner {
        feeBNB = _feeBNB;
    }
    function addPoolRewards(uint256 lAmount) external onlyOwner {
        uint256 liquidityAmount = lAmount * 10**18;
        totalLiquidity += liquidityAmount;
        IBEP20(token).transferFrom(_msgSender(), address(this), liquidityAmount);
    }
    function removePoolRewards() external onlyOwner {
        uint256 removeLiquidity = totalLiquidity;
        totalLiquidity -= removeLiquidity;
        IBEP20(token).transfer(_msgSender(), removeLiquidity);
    }
    function removeTotalValueLocked() external onlyOwner {
        uint256 locked = totalValueLocked;
        totalValueLocked -= locked;
        IBEP20(token).transfer(_msgSender(), locked);
    }
    function emergencialWithdraw(uint256 eAmount) external onlyOwner {
        IBEP20(token).transfer(_msgSender(), eAmount);
    }
    function withdrawBNBManually() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(receiveAddress).transfer(balance);
    }
    function setFeeTax(uint256 _feeTax) external onlyOwner {
        feeTax = _feeTax;
    }
    function setBlockTime(uint256 _timeOne, uint256 _timeTwo) external onlyOwner {
        timeOne = _timeOne;
        timeTwo = _timeTwo;
    }
    function changeToken(address _token) external onlyOwner {
        token = IBEP20(_token);
    }
    function changeReceive(address _receiveAddress) external onlyOwner {
        receiveAddress = _receiveAddress;
    }
    function statusStake(bool _activeStake) external onlyOwner {
        activeStake = _activeStake;
    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    function updateRandom(address newAddress) external onlyOwner {
      Random newRandom = Random(payable(newAddress));
      randons = newRandom;
    }
    function updateDividends(address newAddress) external onlyOwner {
      DividendsPaying newDividends = DividendsPaying(payable(newAddress));
      dividends = newDividends;
    }
    function changeTimeClaim(uint256 time) external onlyOwner {
        dividends.changeTimeClaim(time);
    }
    function changeStoneURI(string calldata _fireStone, string calldata _waterStone, string calldata _soulStone, string calldata _lifeStone) external onlyOwner {
        fireStone = _fireStone;
        waterStone = _waterStone;
        soulStone = _soulStone;
        lifeStone = _lifeStone;
    }
}