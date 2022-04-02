// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./ERC20.sol";
import "./Ownable.sol";
import "./ERC20Burnable.sol";
import "./ERC20Blocklist.sol";
import "./ERC20Register.sol";
import "./ERC20Pausable.sol";


contract test5000 is ERC20, Pausable, Ownable, ERC20Burnable, ERC20Blocklist, ERC20Register{
    
    struct Frozen{
        uint256 amount;
        uint until;
    }
    
    mapping(address => Frozen[]) private frozenTokens;
    
    constructor() ERC20("test5000", "5000") {}
    
    modifier checkFrozenBalance(address account, uint256 amount){
        uint256 frozenBalance = frozenBalanceOf(account);
        uint256 balance = balanceOf(account);
        unchecked {
            require( balance - frozenBalance >= amount, "Attention: The amount you want to transfer is frozen");
        }
        _;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
    
    function mint(address _to, uint256 _amount) external onlyOwner{
        _mint(_to, _amount);
    }

    function MiningRewards(address _to, uint256 _amount) external onlyOwner{
        _MiningRewards(_to, _amount);
    }


    function SetPriceOfRegister(uint256 _PriceOfRegisterSet) public onlyOwner {
      PriceOfRegister = _PriceOfRegisterSet;
    }

    function SetDetails(string memory _newWebSite, string memory _newSourceIPFS, string memory _newAvailableInBlockchain) public onlyOwner {
       WebSite = _newWebSite;
        SourceIPFS = _newSourceIPFS;
         AvailableInBlockchain = _newAvailableInBlockchain;
    }

    function MinersDetails(address Wallet, uint256 _NumberOfMiner, string memory _Location, string memory _HotSpot, string memory _HotSpotFreq, string memory _P2P, string memory _P2PFreq, string memory _IoTSupport, string memory _StorageSupport, string memory _StorageCapacity) public onlyOwner {
       NumberOfMiner[Wallet] = _NumberOfMiner;
       Location[Wallet] = _Location;
       HotSpot[Wallet] = _HotSpot;
            HotSpotFreq[Wallet]  = _HotSpotFreq;
       P2P[Wallet] = _P2P;
           P2PFreq[Wallet] = _P2PFreq;
       IoTSupport[Wallet] = _IoTSupport;
       StorageSupport[Wallet] = _StorageSupport;
        StorageCapacity[Wallet]  = _StorageCapacity;   
    }

    function LoRa(address Wallet, string memory _LoRaSupport, string memory _LoRaFreq) public onlyOwner {
        LoRaSupport[Wallet] = _LoRaSupport;
        LoRaFreq[Wallet] = _LoRaFreq;
    }


    function RPCDetails(string memory _RPCname, string memory _RPCurl, uint256 _ChainID, string memory _BlockExplorerUrl) public onlyOwner {
       RPCname = _RPCname;
        RPCurl = _RPCurl;
         ChainID = _ChainID;
          BlockExplorerUrl = _BlockExplorerUrl;
    }

    function SetNotifications(string memory _newNotifications) public onlyOwner {
        Notifications = _newNotifications;
    }   

    function setPriceOfWalletName(uint256 _PriceOfWalletNameSet) public onlyOwner {
        PriceOfWalletNameSet = _PriceOfWalletNameSet;
    }

    function setWalletName(address Wallet, string memory _WalletNameSet) public payable {
       require(msg.value >= PriceOfWalletNameSet);
        require(Wallet == _msgSender());
         WalletName[Wallet] = _WalletNameSet;
    }
    




    

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
 }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override preventBlockedAccount checkFrozenBalance(sender, amount) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
    
    function approve(address spender, uint256 amount) public virtual override preventBlockedAccount returns (bool) {
        return super.approve(spender, amount);
    }
    
    function transfer(address recipient, uint256 amount) public virtual override preventBlockedAccount checkFrozenBalance(_msgSender(), amount) returns (bool) {
        return super.transfer(recipient, amount);
    }
    
    
    function mintAndFreeze(address _to, uint256 _amount, uint _until) external onlyOwner{
        require(_until > block.timestamp, "_until param should be greater than current block.timestamp");
        Frozen memory _frozen = Frozen(_amount, _until);
        frozenTokens[_to].push(_frozen);
        _mint(_to, _amount);
    }
    
    function frozenBalanceOf(address _account) public view returns(uint256){
        if(frozenTokens[_account].length < 1){
            return 0;
        }
        uint256 totalFrozen = 0;
        for(uint i = 0; i < frozenTokens[_account].length; i++){
            Frozen memory frozen = frozenTokens[_account][i];
            if(frozen.until >= block.timestamp){
                totalFrozen += frozen.amount;
            }
        }
        return totalFrozen;
    }
    
    function currentBlockTimestamp() public view returns(uint){
        return block.timestamp;
    }
}