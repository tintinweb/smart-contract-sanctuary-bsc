// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Math/SafeMath.sol";
import "./Validation.sol";

contract UserShoe is ERC721,Ownable{
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 internal _upperLimitEnergyValue = 20;
    uint256 internal _initialEnergy = 2;
    uint256 internal _initialEfficiency = 0;
    uint256 internal _castingDirectInvitationRewardRatio = 6;
    uint256 internal _castingIndirectInvitationProportions = 3;
    uint256 internal _inviteEveryoneDirectlyToTheEfficiencyScore = 2;
    uint256 internal _inviteEveryoneIndirectToTheEfficiencyScore = 1;


    uint256 internal _shoeRecyclingTotalNumber  = 0;
    uint256 internal _owShoeCastingQuantity = 0;

    uint256 internal _coolingTime = 1 days;

    mapping (address => address) internal _inviterAndInvitee;
    mapping (address => uint256) internal _directInviteesAmount;
    mapping (address => uint256) internal _indirectInviteesAmount;
    mapping (address => uint256) internal _upperLimitEnergy;
    mapping (address => uint256) internal _currentEnergy;
    mapping (address => uint256) internal _currentJoggingMileage;
    mapping (address => uint256) internal _useJoggingCooldown;
    mapping (address => uint256) internal _currentEfficiency;
    mapping (address => uint256) internal _inviteEfficiency;
    mapping (address => uint256) internal _receiveEnergyCooldown;
    mapping (address => ReturnsDetailed[]) internal _LGBReturnsDetailed;

    mapping (address => uint256) internal _mySavingsLGB;

    mapping (uint256 => uint256) internal _shoeOrProp; // 1 is shoe 2 is prop

    mapping (address => bool) internal _admin;

    address payable internal _myLetsGoBro;

    struct ReturnsDetailed{
        uint256 amount;
        uint256 types;
        uint256 times;
    }

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_) ERC721(name_, symbol_) {
        _admin[_msgSender()] = true;
        _myLetsGoBro = myLetsGoBro_;
    }

    modifier onlyAdmin() {
        require(getAdmin(), "Ownable: caller is not the Admin");
        _;
    }

    modifier onlyOwnerOf(uint256 tokenId_) {
        address owner = this.ownerOf(tokenId_);
        require(owner == _msgSender(),"ERC721: you are not the holder");
        _;
    }

    function getMyLetsGoBroAddress() public view returns(address){
        return _myLetsGoBro;
    }

    function setMyLetsGoBroAddress(address payable ERC20Address) public onlyOwner {
        _myLetsGoBro = ERC20Address;
    }

    function getMySavingsLGB() public view returns(uint256){
        return _mySavingsLGB[_msgSender()];
    }

    function addMySavingsLGB (address holder_,uint256 val_) internal {
        _mySavingsLGB[holder_] = _mySavingsLGB[holder_].add(val_);
    }

    function subMySavingsLGB (address holder_,uint256 val_) internal {
        _mySavingsLGB[holder_] = _mySavingsLGB[holder_].sub(val_);
    }

    function withdrawals() public{
        IERC20(_myLetsGoBro).transfer(_msgSender(), _mySavingsLGB[_msgSender()]);
        _mySavingsLGB[_msgSender()] = 0;
        _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_mySavingsLGB[_msgSender()],104,block.timestamp));
    }

    function getAdmin() public view returns(bool){
        return _admin[_msgSender()];
    }

    function setAdmin(address owner_) public onlyOwner{
        _admin[owner_] = !_admin[owner_];
    }

    function findERC20TokenBalanceOf(address token_) public view onlyOwner returns(uint256) {
        return IERC20(token_).balanceOf(address(this));
    }

    function extractERC20Tokens(address token_,address to_,uint256 amount_) public onlyOwner {
        IERC20(token_).transfer(to_, amount_);
    }

    function getUpperLimitEnergy() public view returns(uint256){
        return _upperLimitEnergy[_msgSender()];
    }

    function getCurrentEnergy() public view returns(uint256){
        return _currentEnergy[_msgSender()];
    }

    function getCurrentEfficiency() public view returns(uint256) {
        return _currentEfficiency[_msgSender()];
    }

    function getInviteEfficiency() public view returns(uint256){
        return _inviteEfficiency[_msgSender()];
    }

    function getUpperLimitEnergyValue() public view returns(uint256) {
        return _upperLimitEnergyValue;
    }

    function setUpperLimitEnergyValue(uint256 val_) public onlyOwner {
        _upperLimitEnergyValue = val_;
    }

    function getInitialEnergy() public view returns(uint256) {
        return _initialEnergy;
    }

    function setInitialEnergy(uint256 val_) public onlyOwner {
        _initialEnergy = val_;
    }

    function getInitialEfficiency() public view returns(uint256) {
        return _initialEfficiency;
    }

    function setInitialEfficiency(uint256 val_) public onlyOwner {
        _initialEfficiency = val_;
    }

    function getInviterAndInvitee() public view returns(address){
        return _inviterAndInvitee[_msgSender()];
    }

    function getShoeOrProp(uint256 tokenId_)public view returns(uint256) {
        return _shoeOrProp[tokenId_];
    }

    function getCastingDirectInvitationRewardRatio() public view returns(uint256){
        return _castingDirectInvitationRewardRatio;
    }

    function setCastingDirectInvitationRewardRatio(uint256 val_) public onlyOwner {
        _castingDirectInvitationRewardRatio = val_;
    }

    function getCastingIndirectInvitationProportions() public view returns(uint256){
        return _castingIndirectInvitationProportions;
    }

    function setCastingIndirectInvitationProportions(uint256 val_) public onlyOwner {
        _castingIndirectInvitationProportions = val_;
    }

    function getInviteEveryoneDirectlyToTheEfficiencyScore() public view returns(uint256){
        return _inviteEveryoneDirectlyToTheEfficiencyScore;
    }

    function setInviteEveryoneDirectlyToTheEfficiencyScore(uint256 val_) public onlyOwner {
        _inviteEveryoneDirectlyToTheEfficiencyScore = val_;
    }

    function getInviteEveryoneIndirectToTheEfficiencyScore() public view returns(uint256) {
        return _inviteEveryoneIndirectToTheEfficiencyScore;
    }

    function setInviteEveryoneIndirectToTheEfficiencyScore(uint256 val_) public onlyOwner {
        _inviteEveryoneIndirectToTheEfficiencyScore = val_;
    }

    function triggerCoolingTime() internal view returns(uint256){
        return (block.timestamp + _coolingTime) - ((block.timestamp + _coolingTime) % 1 days);
    }

    function verifyCooling(uint256 times_) internal view returns(bool){
        return (times_ <= block.timestamp);
    }

    function setInviterAddress(address inviter_) internal {
        address indirectInviter = _inviterAndInvitee[inviter_];
        if(_inviterAndInvitee[_msgSender()] == address(0) && indirectInviter != _msgSender() && inviter_ != _msgSender()){
            _directInviteesAmount[inviter_]++;
            _inviteEfficiency[inviter_] = _inviteEfficiency[inviter_].add(_inviteEveryoneDirectlyToTheEfficiencyScore);
            _inviterAndInvitee[_msgSender()] = inviter_;
            if(indirectInviter != address(0)){
                _inviteEfficiency[indirectInviter] = _inviteEfficiency[indirectInviter].add(_inviteEveryoneIndirectToTheEfficiencyScore);
                _indirectInviteesAmount[indirectInviter]++;
            }
        }
    }

    function getNumberDirectInvitees() public view returns(uint256){
        return _directInviteesAmount[_msgSender()];
    }

    function getNumberIndirectInvitees () public view returns(uint256){
        return _indirectInviteesAmount[_msgSender()];
    }

    function collectDilyEnergyValue() public {
        require(verifyCooling(_receiveEnergyCooldown[_msgSender()]),"ERC721: Please come back tomorrow for energy");
        uint256 gainEnergy = _directInviteesAmount[_msgSender()].mul(2).add(_indirectInviteesAmount[_msgSender()].add(_initialEnergy));
        if(gainEnergy > _upperLimitEnergyValue){
            gainEnergy = _upperLimitEnergyValue;
        }
        _upperLimitEnergy[_msgSender()] = gainEnergy;
        _currentEnergy[_msgSender()] = gainEnergy;
        _receiveEnergyCooldown[_msgSender()] = triggerCoolingTime();
    }

    function addCurrentEnergy(uint256 energy_) internal {
        uint256 _addenergy = _currentEnergy[_msgSender()].add(energy_);
        require(_addenergy < _upperLimitEnergy[_msgSender()],"ERC721: Your energy is already full");
        _currentEnergy[_msgSender()] += _addenergy;
    }

    function getCurrentJoggingMileage() public view returns(uint256) {
        return _currentJoggingMileage[_msgSender()];
    }

    function addCurrentJoggingMileage(uint256 mileage_) internal {
        _currentJoggingMileage[_msgSender()] = _currentJoggingMileage[_msgSender()].add(mileage_);
    }

    function addCurrentEfficiency(uint256 efficiency_) internal {
        _currentEfficiency[_msgSender()] = efficiency_;
    }

    function collectMoney(uint256 money_) internal {
        if(_mySavingsLGB[_msgSender()] >= money_){
            subMySavingsLGB(_msgSender(),money_);
        }
        else{
            uint256 LGBBalance = IERC20(_myLetsGoBro).allowance(_msgSender(), address(this));
            require(LGBBalance >= money_,"ERC721: Your approve LGB balance is insufficient");
            IERC20(_myLetsGoBro).transferFrom(_msgSender(),address(this),money_);
        }
    }

    function getRandom(uint256 max_) internal view returns (uint256) {
        uint256 rancom_ = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        return uint256(
            (rancom_ % max_) + 1
        );
    }
    
}

contract ShoeNFT is UserShoe{
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdCounter;
    using Strings for uint256;
    using SafeMath for uint256;

    string private baseURI = "https://letsgobro.io/";

    uint256 private _shoeCastingPrice = 100 ether; //100LGB
    uint256 private _shoeRecyclingPrice = 50 ether; // 50LGB

    bool private _shoeCastingSwitch = false;

    mapping (uint256 => uint256) private _shoeOdds; // 1 N = 56; 2 R = 36; 3 SR = 10; 4 SSR = 2;

    mapping (uint256 => uint256) private _lvNumber; 

    mapping (uint256 => string) internal _shoeLvURI;

    mapping (uint256 => ShoeTokenMeta) internal _shoeData;

    mapping (uint256 => uint256) internal _shoeLvURINumber;

    struct ShoeTokenMeta {
        uint256 lv;
        uint256 soldTimes;
        uint256 shoeDurable;
        uint256 shoeMiles;
        uint256 luckyValue;
        uint256 cooldown;
        bool isAdminMinter;
        string uri;
        address minter;
    }

    struct ShoesProps{
        uint256 tokenId;
        uint256 typeIndex;
    }

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_) UserShoe(name_, symbol_,myLetsGoBro_) {

    }

    function getLvNumber(uint256 lv_) public view onlyAdmin returns(uint256) {
        return _lvNumber[lv_];
    }

    function getShoeCastingSwitch() public view returns(bool){
        return _shoeCastingSwitch;
    }

    function setShoeCastingSwitch() public onlyOwner {
        _shoeCastingSwitch = !_shoeCastingSwitch;
    }

    function setShoeOdds (uint256 lv_,uint256 val_) public onlyOwner{
        _shoeOdds[lv_] = val_;
    }

    function getShoeOdds (uint256 lv_) public view returns(uint256){
        return _shoeOdds[lv_];
    }

    function getShoeRecyclingPrice() public view onlyOwner returns(uint256) {
        return _shoeRecyclingPrice;
    }

    function setShoeRecyclingPrice(uint256 val_) public onlyOwner {
        _shoeRecyclingPrice = val_;
    }

    function getShoeCastingPrice() public view returns(uint256){
        return _shoeCastingPrice;
    }

    function setShoeCastingPrice(uint256 val_) public onlyOwner {
        _shoeCastingPrice = val_;
    }


    function getOwShoeCastingQuantity() public view onlyAdmin returns(uint256) {
        return _owShoeCastingQuantity;
    }

    function getShoeRecyclingTotalNumber() public view onlyAdmin returns(uint256) {
        return _shoeRecyclingTotalNumber;
    }

    function setBaseURI(string memory newBaseURI_) public onlyOwner {
        baseURI = newBaseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setShoeLvURI(uint256 lv_,string memory URI_) public onlyAdmin {
        _shoeLvURI[lv_] = URI_;
    }

    function getShoeJoggingCooldown(uint256 tokenId_) public view returns(bool) {
        return verifyCooling(_shoeData[tokenId_].cooldown);
    }

    function shoeTokenMeta(uint256 tokenId_) public view returns (ShoeTokenMeta memory) {
        return _shoeData[tokenId_];
    }

    function setInviterAndInviteeFee(address inviter_) internal {
        uint256 directInvitationReward = _shoeCastingPrice.mul(_castingDirectInvitationRewardRatio).div(100);
        addMySavingsLGB(inviter_,directInvitationReward);
        _LGBReturnsDetailed[inviter_].push(ReturnsDetailed(directInvitationReward,1,block.timestamp));
        address _indirectInviter = _inviterAndInvitee[inviter_];
        if(_indirectInviter != address(0)){
            uint256 indirectInvitationReward = _shoeCastingPrice.mul(_castingIndirectInvitationProportions).div(100);
            addMySavingsLGB(_indirectInviter,indirectInvitationReward);
            _LGBReturnsDetailed[_indirectInviter].push(ReturnsDetailed(indirectInvitationReward,2,block.timestamp));
        }
    }

    function shoeOddsGetLv(uint256 random_) private view returns(uint256)  {
        
        if(random_ <= _shoeOdds[1])
            return 1;
        if(random_ <= _shoeOdds[2])
            return 2;
        if(random_ <= _shoeOdds[3])
            return 3;
        if(random_ <= _shoeOdds[4])
            return 4;
        revert("ERC721: Lv Abnormal casting");
    }

    function getOwnerAllShoeNFT() public view returns(ShoesProps[] memory) {
        ShoesProps[] memory _tokenId = new ShoesProps[](balanceOf(_msgSender()));
        uint256 counter = 0;
        for(uint256 i = 1;i <= totalSupply();i++){
            if(ownerOf(i) == _msgSender()){
                _tokenId[counter].tokenId = i;
                _tokenId[counter].typeIndex = _shoeOrProp[i];
                counter++;
            }
        }
        return _tokenId;
    }

    function totalSupply() public view returns(uint256) {
        return _tokenIdCounter.current();
    }

    function addTokenId() internal returns(uint256) {
        _tokenIdCounter.increment();
        uint256 _tokenId = _tokenIdCounter.current();
        return(_tokenId);
    }

    function isUR(uint256 tokenId_) public view returns(bool){
        return _shoeData[tokenId_].isAdminMinter;
    }


    function shoeSafeMint(address inviter_) public {
        bool admin_ = getAdmin();
        if(admin_){
            _owShoeCastingQuantity++;
        }
        else{
            require(_shoeCastingSwitch,"ERC721: Casting switch not turned on");
            collectMoney(_shoeCastingPrice);
            _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_shoeCastingPrice,101,block.timestamp));
            address _inviter = _inviterAndInvitee[_msgSender()];
            if(_inviter != address(0)){
                setInviterAndInviteeFee(_inviter);
            }
            else{
                setInviterAddress(inviter_);
                setInviterAndInviteeFee(inviter_);
            }
        }

        uint256 _tokenId = addTokenId();
        _shoeOrProp[_tokenId] = 1;
        ShoeTokenMeta memory meta = _shoeData[_tokenId];
        if(admin_){
            meta.lv = 3;
            meta.uri = string(abi.encodePacked(_shoeLvURI[5], getRandom(_shoeLvURINumber[5]).toString())); //tokenURI(tokenId)
        }
        else{
            uint256 random_ = getRandom(100);
            uint256 lv_ = shoeOddsGetLv(random_);
            _lvNumber[lv_]++;
            meta.lv = lv_;
            meta.luckyValue = random_;
            meta.uri = string(abi.encodePacked(_shoeLvURI[lv_], getRandom(_shoeLvURINumber[lv_]).toString())); //tokenURI(tokenId)
        }
        meta.isAdminMinter = admin_;
        meta.minter = _msgSender();
        meta.shoeDurable = 30;
        meta.soldTimes = block.timestamp;
        
        if(_upperLimitEnergy[_msgSender()] == 0){
            _upperLimitEnergy[_msgSender()] = _initialEnergy;
            collectDilyEnergyValue();
        }

        _shoeData[_tokenId] = meta;

        _safeMint(_msgSender(), _tokenId);
    }

    function shoeRecycling (uint256 tokenId_) public  onlyOwnerOf(tokenId_) {
        ShoeTokenMeta memory meta = _shoeData[tokenId_];
        require(!meta.isAdminMinter,"ERC721: Gifts cannot be recycled");
        require(meta.shoeDurable == 30,"ERC721: Requires durability of 30 points");
        delete _shoeData[tokenId_];
        _shoeRecyclingTotalNumber++;
        _burn(tokenId_);
        addMySavingsLGB(_msgSender(),_shoeRecyclingPrice);
        _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_shoeRecyclingPrice,4,block.timestamp));
    }

}

contract ShoeAssistant is ShoeNFT{
    using Strings for uint256;

    mapping (uint256 => uint256) internal _shoeSynthesisFee; // 1 N = 1000; 2 R = 1500; 3 SR || UR = 3000 4 SSR = 6000;

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_) ShoeNFT(name_, symbol_,myLetsGoBro_){
    }

    function setShoeSynthesisFee(uint256 lv_,uint256 val_) public onlyOwner {
        _shoeSynthesisFee[lv_] = val_;
    }

    function getShoeSynthesisFee(uint256 lv_) public view returns(uint256){
        return _shoeSynthesisFee[lv_];
    }

    function syntheticNewShoes(uint256[] memory tokenId_) public {
        uint256 _length = tokenId_.length;
        require(_length >= 3 && _length <= 5,"ERC721: Please put in 3 to 5 pairs of shoes");
        uint8 _lucky = 0;
        ShoeTokenMeta memory _ShoeMeta = _shoeData[tokenId_[0]];
        collectMoney(_shoeSynthesisFee[_ShoeMeta.lv]);
        _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_shoeSynthesisFee[_ShoeMeta.lv],102,block.timestamp));
        for (uint8 i = 0;i < _length; i++){
            address owner = this.ownerOf(tokenId_[i]);
            require(owner == _msgSender(),"ERC721: you are not the holder");
            ShoeTokenMeta memory _meta = _shoeData[tokenId_[i]];
            require(_ShoeMeta.lv == _meta.lv,"ERC721: You need the same level to be able to synthesize");
            _lucky = _lucky + (_meta.isAdminMinter ? 20 : 10);
            if(i > 0){
                delete _shoeData[tokenId_[i]];
                _burn(tokenId_[i]);
            }
        }
        uint256 random_ = getRandom(100);
        if(random_ <= _lucky){
            uint256 _lv = _ShoeMeta.lv < 4 ? _ShoeMeta.lv + 1 : 4;
            _ShoeMeta.lv = _lv;
        _ShoeMeta.uri = string(abi.encodePacked(_shoeLvURI[_lv], getRandom(_shoeLvURINumber[_lv]).toString())); //tokenURI(tokenId)
        }
        _ShoeMeta.luckyValue = random_;
        _ShoeMeta.shoeDurable = 30;
        _ShoeMeta.isAdminMinter = false;
        _ShoeMeta.minter = _msgSender();

        _shoeData[tokenId_[0]] = _ShoeMeta;
    }
}

contract ShoeJogging is ShoeAssistant{
    using SafeMath for uint256;
    uint256 internal _LGBRatioIsObtainedByRunningSteps = 10;
    uint256 internal _LGBConversionProportion = 10000;

    address payable private _validationSeed;

    mapping (uint256 => uint256) internal _lvJoggingLimit; // 1 N = 3000; 2 R = 4500; 3 SR || UR = 9000 4 SSR = 18000;

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_,address payable validationSeed_) ShoeAssistant(name_, symbol_,myLetsGoBro_){
        _validationSeed = validationSeed_;
    }

    function getValidationSeedAddress () public view returns(address){
        return _validationSeed;
    }

    function setValidationSeedAddress (address payable validationSeed_) public onlyOwner {
        _validationSeed = validationSeed_;
    }

    function getLGBRatioIsObtainedByRunningSteps () public view onlyOwner returns(uint256){
        return _LGBRatioIsObtainedByRunningSteps;
    }

    function setLGBRatioIsObtainedByRunningSteps (uint256 val_) public onlyOwner {
        _LGBRatioIsObtainedByRunningSteps = val_;
    }

    function getLGBConversionProportion() public view onlyOwner returns(uint256){
        return _LGBConversionProportion;
    }

    function setLGBConversionProportion(uint256 val_) public onlyOwner {
        _LGBConversionProportion = val_;
    }

    function getLvJoggingLimit (uint256 lv_) public view returns(uint256) {
        return _lvJoggingLimit[lv_];
    }

    function setLvJoggingLimit (uint256 lv_, uint256 val_) public onlyOwner{
        _lvJoggingLimit[lv_] = val_;
    }

    function shoeJoggingReward(uint256 tokenId_,uint256 mileage_,uint256 code_) public onlyOwnerOf(tokenId_) {
        if(!verifyCooling(_useJoggingCooldown[_msgSender()])){
            _currentJoggingMileage[_msgSender()] = 0;
        }
        require(Validation(_validationSeed).getVerificationCode() == code_,"ERC721: Jogging failure");
        require(_shoeOrProp[tokenId_] == 1,"ERC721: Please use shoes jogging");
        require(_currentEnergy[_msgSender()] > 0,"ERC721: Your energy value must be greater than 0");
        _currentEnergy[_msgSender()]--;
        require(_shoeData[tokenId_].shoeDurable > 0,"ERC721: Your durability value must be greater than 0");
        require(verifyCooling(_shoeData[tokenId_].cooldown),"ERC721: Please come back tomorrow jogging");
        _shoeData[tokenId_].shoeDurable--;
        uint256 _jogging = _currentJoggingMileage[_msgSender()] + mileage_;
        if(_jogging > _lvJoggingLimit[_shoeData[tokenId_].lv])
            _jogging = _lvJoggingLimit[_shoeData[tokenId_].lv];
        _shoeData[tokenId_].shoeMiles += _jogging;
        uint256 _Efficiency = 100 + _currentEfficiency[_msgSender()];
        uint256 _conversionLGB = _jogging * 10 ** 18;
        uint256 _LGB = _conversionLGB.mul(_LGBRatioIsObtainedByRunningSteps).div(_LGBConversionProportion).mul(_Efficiency).div(100);
        addMySavingsLGB(_msgSender(),_LGB);
        _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_LGB,3,block.timestamp));
        _currentEfficiency[_msgSender()] = 0;
        _shoeData[tokenId_].cooldown = triggerCoolingTime();
        Validation(_validationSeed).setVerificationCode();
    }
}

contract PropsNFT is ShoeJogging {
    using Strings for uint256;
    
    uint256 internal _gashaponPropsPrice = 1 ether; //1LGB

    uint256 internal _propsTotalNumber = 0;
    
    uint256 internal _owPropsCastingQuantity = 0;

    mapping (uint256 => PropsTokenMeta) _propsData;

    PropsTokenMeta[] internal _shopPropsTokenMeta;

    bool internal _propsCastingSwitch = false;

    struct PropsTokenMeta {
        uint256 jogging;
        uint256 energy;
        uint256 efficiency;
        uint256 propsOdds;
        string uri;
    }

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_,address payable validationSeed_) ShoeJogging(name_, symbol_,myLetsGoBro_,validationSeed_){
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        _requireMinted(tokenId_);
        if(_shoeOrProp[tokenId_] == 1)
            return _shoeData[tokenId_].uri;
        else
            return _propsData[tokenId_].uri;
    }

    function addGashaponProp(uint256 jogging,uint256 energy,uint256 efficiency,uint256 propsOdds,string memory uri) public onlyAdmin {
        _shopPropsTokenMeta.push(PropsTokenMeta(jogging,energy,efficiency,propsOdds,uri));
    }

    function deleteGashaponProp(uint8 index_) public onlyAdmin{
        require(index_ < _shopPropsTokenMeta.length,"ERC721: index out of bound");

        for (uint8 i = index_;i < _shopPropsTokenMeta.length;i++){
            _shopPropsTokenMeta[i] = _shopPropsTokenMeta[i+1];
        }

        _shopPropsTokenMeta.pop();
    }

    function setGashaponPropsPrice(uint256 val_) public onlyAdmin {
        _gashaponPropsPrice = val_;
    }

    function getGashaponPropsPrice() public view returns(uint256) {
        return _gashaponPropsPrice;
    }

    function getPropsCastingSwitch() public view returns(bool) {
        return _propsCastingSwitch;
    }

    function getPropsTotalNumber() public view returns(uint256){
        return _propsTotalNumber;
    }

    function getOwPropsCastingQuantity() public view onlyAdmin returns(uint256){
        return _owPropsCastingQuantity;
    }

    function setPropsCastingSwitch() public onlyAdmin{
        _propsCastingSwitch = !_propsCastingSwitch;
    }

    function propsTokenMeta(uint256 tokenId_) public view returns (PropsTokenMeta memory) {
        return _propsData[tokenId_];
    }

    function shopPropsTokenMeta() public view returns (PropsTokenMeta[] memory) {
        return _shopPropsTokenMeta;
    }

    function openGashaponOrops() public {
        bool admin_ = getAdmin();
        if(admin_){
            _owPropsCastingQuantity++;
        }
        else{
            require(_propsCastingSwitch,"ERC721: Casting switch not turned on");
            collectMoney(_gashaponPropsPrice);
            _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_gashaponPropsPrice,103,block.timestamp));
        }
        uint256 _tokenId = addTokenId();
        _shoeOrProp[_tokenId] = 2;
        _propsTotalNumber++;
        uint256 random_ = getRandom(100);
        for(uint8 i = 0;i < _shopPropsTokenMeta.length;i++){
            if(random_ <= _shopPropsTokenMeta[i].propsOdds){
                _propsData[_tokenId] = _shopPropsTokenMeta[i];
                break;
            }
        }
        _safeMint(_msgSender(), _tokenId);
    }

}

contract PropsAssistant is PropsNFT{

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_,address payable validationSeed_) PropsNFT(name_, symbol_,myLetsGoBro_,validationSeed_){}

    function useProps(uint256 tokenId_) public onlyOwnerOf(tokenId_) {
        require(_shoeOrProp[tokenId_] == 2,"ERC721: Please use Props");
        if(_propsData[tokenId_].jogging > 0){
            if(!verifyCooling(_useJoggingCooldown[_msgSender()])){
            _currentJoggingMileage[_msgSender()] = 0;
            }
            addCurrentJoggingMileage(_propsData[tokenId_].jogging);
            _useJoggingCooldown[_msgSender()] = triggerCoolingTime();
        }
        if(_propsData[tokenId_].energy > 0){
            addCurrentEnergy(_propsData[tokenId_].energy);
        }
        if(_propsData[tokenId_].efficiency > 0){
            addCurrentEfficiency(_propsData[tokenId_].efficiency);
        }
        delete _propsData[tokenId_];
        _burn(tokenId_);
    }

}

interface MyCNFT is IERC721 {

    function totalSupply() external view returns(uint256);

}

contract TradingMarket is PropsAssistant{
    using Counters for Counters.Counter;
    Counters.Counter internal _marketIdCounter;
    using SafeMath for uint256;

    uint256 public marketTax = 3;
    uint256 public trandsNFTSharesProfits = 3;
    uint256 public URMarketRoyalties = 4;
    uint256 public minimumSellingPrice = 10 ** 18;

    address payable public creationNFTAddress;

    struct OrderData {
        address sellers;
        IERC721 ERC721Address;
        uint256 salePrice;
        uint256 tokenId;
    }

    mapping (uint256 => OrderData) public orderData;

    event GoodsSell (uint256 tokenId,address sell,uint256 price);
    event GoodsPurchased (uint256 tokenId,address sell,uint256 price);

    constructor(string memory name_, string memory symbol_,address payable myLetsGoBro_,address payable validationSeed_,address payable creationNFTAddress_) PropsAssistant(name_, symbol_,myLetsGoBro_,validationSeed_) {
        creationNFTAddress = creationNFTAddress_;
    }

    function taxCalculation(IERC721 ERC721Address,uint256 tokenId_,uint256 price_) private view returns(uint256) {
        if(ERC721Address == this && this.isUR(tokenId_)){
            return price_ + price_.mul(marketTax + trandsNFTSharesProfits + URMarketRoyalties).div(100);
        }
        else{
            return price_ + price_.mul(marketTax + trandsNFTSharesProfits).div(100);
        }
    }

    function sellMyStuff (IERC721 ERC721Address,uint256 tokenId_,uint256 price_) public {
        uint256 _fee = taxCalculation(ERC721Address,tokenId_,price_);
        require(price_ >= _fee,"Market: Please enter the lowest price plus tax");
        uint256 id = _marketIdCounter.current();
        _marketIdCounter.increment();
        orderData[id] = OrderData(_msgSender(),ERC721Address,price_,tokenId_);
        require(ERC721Address.ownerOf(tokenId_) == _msgSender(),"Market: You are not the token owner");
        require(super._isApprovedOrOwner(_msgSender(),tokenId_),"Market: caller is not token owner nor approved");
        emit GoodsSell (tokenId_,_msgSender(),price_);
    }

    function buyGoods (IERC721 ERC721Address,uint256 tokenId_,uint256 id_) public {
        uint256 _goodsPrice = orderData[id_].salePrice;
        uint256 _fee = taxCalculation(ERC721Address,tokenId_,_goodsPrice);
        uint256 _priceFee = orderData[id_].salePrice + _fee;
        collectMoney(_priceFee);
        _LGBReturnsDetailed[orderData[id_].sellers].push(ReturnsDetailed(_priceFee,5,block.timestamp));
        _LGBReturnsDetailed[_msgSender()].push(ReturnsDetailed(_priceFee,105,block.timestamp));
        addMySavingsLGB(orderData[id_].sellers,orderData[id_].salePrice);
        uint256 myCNFTLength = MyCNFT(creationNFTAddress).totalSupply();
        uint256 myCNFTBonusFee = _goodsPrice.mul(trandsNFTSharesProfits).div(100).div(300);
        for(uint256 i = 1;i <= myCNFTLength; i++){
            addMySavingsLGB(MyCNFT(creationNFTAddress).ownerOf(i),myCNFTBonusFee);
        }
        delete orderData[id_];
        emit GoodsPurchased (tokenId_,_msgSender(),_goodsPrice);
    }

    function setMarketTax (uint256 val_) public onlyOwner {
        marketTax = val_;
    }

    function setTrandsNFTSharesProfits (uint256 val_) public onlyOwner {
        trandsNFTSharesProfits = val_;
    }

    function setURMarketRoyalties(uint256 val_) public onlyOwner {
        URMarketRoyalties = val_;
    }

    function setMinimumSellingPrice (uint256 val_) public onlyOwner {
        minimumSellingPrice = val_;
    }

    function setCreationNFTAddress (address payable adr_) public onlyOwner {
        creationNFTAddress = adr_;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface Validation {

    function getVerificationCode() external view returns (uint256 balance);

    function setVerificationCode() external;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}