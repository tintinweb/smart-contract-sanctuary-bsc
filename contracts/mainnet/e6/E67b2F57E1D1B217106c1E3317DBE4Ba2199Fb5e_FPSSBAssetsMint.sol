/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface FPSSB{
    function changeManager(address _new_manager) external;
	function setLiquidityReserve(address addr) external;
    function GaiaMint(address _Addr, uint8 _typeID, uint8 _rarityID) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
	
	function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
	function CheckTraitData(uint tokenId) external view returns (uint8 stype, uint publicMTC, uint redeemMTC, address ArinaChain, uint CitizensQuota);
	function setTraitDataGaia(uint _tokenID, uint8 stype, uint publicMTC, uint redeemMTC, address ArinaChain, uint CitizensQuota) external;
}

contract FPSSBAssetsMint {

	address _FPCitizenAddr = 0x69AF985F63B1937F3C96a671F523b8c96eEBFbdA;
	address _FPAssetsAddr = 0x027b5bc111f375AC858d9D51F0B50a3d791C31E5;
	address _MTCAddr = 0x5F1D2cfDEB097B83eD2f35Cf3E827DE2b700F05a;
	address _Owner;
	address _Gaia1;
	address _Gaia2;
	address _Gaia3;
	
	//uint256 public ActiveTime = 1649822400;       //Wed Apr 13 2022 12:00:00 UTC+0800
	uint256 public ActiveTime = 1649520000;       //Wed Apr 13 2022 12:00:00 UTC+0800
	uint256 public PublicTime = 1649952000;       //Fri Apr 15 2022 00:00:00 UTC+0800
	
	uint256 public SSBMintAmounts = 0;
	uint256 public SSBMAXAmounts = 2000;
	
    bool public saleIsActive = true;

    mapping (uint8 => uint256) public _SSBWhiteAmounts;
    mapping (uint256 => uint256) public _UsersSSBBuy;

    constructor() public {
        _Owner = msg.sender;
		_Gaia1 = msg.sender;
		_Gaia2 = msg.sender;
		_Gaia3 = msg.sender;
		_SSBWhiteAmounts[0] = 0;
		_SSBWhiteAmounts[1] = 0;
		_SSBWhiteAmounts[2] = 10;
		_SSBWhiteAmounts[3] = 100;
    }

    function MintSSBAmounts() public view virtual returns (uint) {
        return SSBMintAmounts;
    }

    function owner() public view virtual returns (address) {
        return _Owner;
    }

    function Gaia1() public view virtual returns (address) {
        return _Gaia1;
    }

    function Gaia2() public view virtual returns (address) {
        return _Gaia2;
    }	

    function Gaia3() public view virtual returns (address) {
        return _Gaia3;
    }
	
    modifier onlyOwner{
        require(msg.sender == _Owner, "Ownable: caller is not the owner");
        _;
    }
	
    modifier onlyGaia() {
        require(msg.sender == Gaia1() || msg.sender == Gaia2() || msg.sender == Gaia3() || msg.sender == _Owner, "Ownable: caller is not the Gaia");
        _;
    }

    function changeMTCManager(address _new_manager) external onlyOwner{
        FPSSB(_MTCAddr).changeManager(_new_manager);
    }
	
	function setMTCLR(address addr) external onlyOwner{
        FPSSB(_MTCAddr).setLiquidityReserve(addr);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_Owner, newOwner);
        _Owner = newOwner;
    }
	
    function withdraw() external onlyOwner {
        uint ETHbalance = address(this).balance;
        msg.sender.transfer(ETHbalance);
    }

    function withdraw_ETH(uint _ETHbalance) external onlyOwner{
        msg.sender.transfer(_ETHbalance);
    }

    function takeTokensToManager(address tokenAddr) external onlyOwner{
        uint _thisTokenBalance = FPSSB(tokenAddr).balanceOf(address(this));
        require(FPSSB(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event EventSSBMint(uint ESSBAmounts, bool result);

	function flipSaleState() public onlyOwner {
		saleIsActive = !saleIsActive;
	}
	
    function setALLAddr(address _sFPCitizenAddr, address _sFPAssetsAddr, address _sMTCAddr) public onlyOwner {
		_FPCitizenAddr = _sFPCitizenAddr;
		_FPAssetsAddr = _sFPAssetsAddr;
		_MTCAddr = _sMTCAddr;
    }

    function setGaia1Addr(address _sGaia1) public onlyOwner {
        _Gaia1 = _sGaia1;
    }

    function setGaia2Addr(address _sGaia2) public onlyOwner {
        _Gaia2 = _sGaia2;
    }

    function setGaia3Addr(address _sGaia3) public onlyOwner {
        _Gaia3 = _sGaia3;
    }
	
    function IsActiveTime() public view returns (bool) {
        return block.timestamp >= ActiveTime;
    }
	
    function IsPublicTime() public view returns (bool) {
        return block.timestamp >= PublicTime;
    }
	
	function setActiveTime(uint xActiveTime) public onlyOwner{
        ActiveTime = xActiveTime;
    }
	
	function setPublicTime(uint xPublicTime) public onlyOwner{
        PublicTime = xPublicTime;
    }
	
    function CheckCSbalanceOf(address addr) public view returns (uint256 tokenId) {
        return FPSSB(_FPCitizenAddr).balanceOf(addr);
    }
	
    function ChecktokenIDOfOwner(address addr, uint256 index) public view returns (uint256 tokenId) {
        return FPSSB(_FPCitizenAddr).tokenOfOwnerByIndex(addr, index);
    }
	
    function ChecktokenIDSSB(uint256 _tokenID) public view returns (uint) {
        (uint8 Xtype, , , , ) = FPSSB(_FPCitizenAddr).CheckTraitData(_tokenID);
        uint _addAmounts = _SSBWhiteAmounts[Xtype] - _UsersSSBBuy[_tokenID];
        return _addAmounts;
    }
	
	function CheckAllID(address addr) public view returns (uint[] memory) {
        uint _balanceOf = FPSSB(_FPCitizenAddr).balanceOf(addr);
		uint[] memory tokenIDReturn = new uint[](_balanceOf);
        for (uint i = 0; i < _balanceOf; i++){
		    tokenIDReturn[i] = FPSSB(_FPCitizenAddr).tokenOfOwnerByIndex(addr, i);
        }
        return tokenIDReturn;
    }
	
    function CheckAllpublicSSB(address addr) public view returns (uint _AllpublicMTC) {
        uint _balanceOf = FPSSB(_FPCitizenAddr).balanceOf(addr);
		uint totalpublicSSB = 0;

        for (uint i = 0; i < _balanceOf; i++){
		    uint tokenIDReturn = FPSSB(_FPCitizenAddr).tokenOfOwnerByIndex(addr, i);
		    (uint8 Xtype, , , , ) = FPSSB(_FPCitizenAddr).CheckTraitData(tokenIDReturn);
		    uint _addAmounts = _SSBWhiteAmounts[Xtype] - _UsersSSBBuy[tokenIDReturn];
		    totalpublicSSB = totalpublicSSB + _addAmounts;
        }
        return totalpublicSSB;
    }
	
	
    function GaiaSSBMint(address _Addr) public onlyGaia {
        require(IsTimeActive(), "Sale must be active to mint SSB");
		FPSSB(_FPAssetsAddr).GaiaMint(_Addr, 15, 5);
    }
	
    function GaiaSSBMintBatch(address[] memory _deliveryAddrs) public onlyGaia {
        require(IsTimeActive(), "Sale must be active to mint SSB");
        uint _addressAmount = _deliveryAddrs.length;
        for(uint i = 0; i < _addressAmount; i++) {
			FPSSB(_FPAssetsAddr).GaiaMint(_deliveryAddrs[i], 15, 5);
        }
    }
	
    function _SSBMint(address _Addr) internal virtual {
		FPSSB(_FPAssetsAddr).GaiaMint(_Addr, 0, 5);
    }
	
    function _SSBMintBatch(uint _SSBAmounts, address _Addr)internal virtual {
        for(uint i = 0; i < _SSBAmounts; i++) {
			FPSSB(_FPAssetsAddr).GaiaMint(_Addr, 0, 5);
        }
    }

	function SSBMint(uint _SSBAmounts) public {
		if(!IsPublicTime()){
			require(IsTimeActive() && IsActiveTime(), "Sale must be active to mint SSB");
			require(SSBMintAmounts + _SSBAmounts <= SSBMAXAmounts, "SSB Mint amounts must be less than SSBMAXAmounts");
			address inputAddr = msg.sender;
			uint xAllpublicSSB = CheckAllpublicSSB(inputAddr);

			require(xAllpublicSSB >= _SSBAmounts, "SSB Sale : SSB sale quota has been exhausted.");

			_SSBMintBatch(_SSBAmounts, inputAddr);
			SSBMintAmounts = SSBMintAmounts + _SSBAmounts;
			emit EventSSBMint(_SSBAmounts, true);
			
			uint _balanceOf = FPSSB(_FPCitizenAddr).balanceOf(inputAddr);
			for (uint i = 0; i < _balanceOf; i++){
				uint tokenIDReturn = FPSSB(_FPCitizenAddr).tokenOfOwnerByIndex(inputAddr, i);
				(uint8 Xtype, , , , ) = FPSSB(_FPCitizenAddr).CheckTraitData(tokenIDReturn);
				uint _addAmounts = _SSBWhiteAmounts[Xtype] - _UsersSSBBuy[tokenIDReturn];
				if(_addAmounts < _SSBAmounts && _addAmounts != 0){
					_UsersSSBBuy[tokenIDReturn] = _SSBWhiteAmounts[Xtype];
					_SSBAmounts = _SSBAmounts - _addAmounts;
				}else{
					_UsersSSBBuy[tokenIDReturn] = _UsersSSBBuy[tokenIDReturn] - _SSBAmounts;
					_SSBAmounts = 0;
				}
			}
			
		}else{
			require(IsTimeActive() && IsActiveTime(), "Sale must be active to mint SSB");
			require(SSBMintAmounts + _SSBAmounts <= SSBMAXAmounts, "SSB Mint amounts must be less than SSBMAXAmounts");
			address inputAddr = msg.sender;

			_SSBMintBatch(_SSBAmounts, inputAddr);
			SSBMintAmounts = SSBMintAmounts + _SSBAmounts;
			emit EventSSBMint(_SSBAmounts, true);
		}
    }

    function IsTimeActive() public view returns (bool) {
        return saleIsActive;
    }
	
	function destroy() external onlyOwner{ 
        selfdestruct(msg.sender); 
	}
}