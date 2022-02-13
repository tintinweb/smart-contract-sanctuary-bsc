/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity 0.8.11;

contract OreForgeEternalStorage {
    address private _owner = msg.sender; // Permanent (managed seperately from the current frontend
    address private _latestVersion; // Current frontend address
    uint256[] private _nftIds; //TODO Is the intent to restrict READ access to the frontEnd only? NOOO!
    address private _paymentAddress = msg.sender; // Where to receive the fees
    address[] private _paymentTokens;    // Tokens accepted as payment

    // Fee Data Structs
    string[] private _feeIndex;
    mapping(string => uint256) private _fees;

    /* NFT Record data structs //NOT USED BC SOLIDITY DOESN'T PROPERLY SUPPORT STRUCT
    struct ownersrecord {
        address owner;
        uint256 quantity;
    }
    mapping(uint256 => ownersrecord[]) private _nftRecords; //nftId => ownersrecord[]
    */ // Use instead >>>
    mapping(uint256 => address[]) private _nftOwners;
    mapping(uint256 => uint256[]) private _nftQuantities;

    mapping(uint256 => mapping(address => uint)) private _nftOwnersIndexes; //nftId => (wallet => index)

    ///// Utility //////
    function pushOwnersRecord(uint256 nftId, address nftOwner, uint256 quantity) internal {
        _nftOwners[nftId].push(nftOwner);
        _nftQuantities[nftId].push(quantity);
    }
    function _isEqual(string storage str1, string calldata str2) internal pure returns (bool){
        bool result = false;
        if (keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2))){
            result = true;
        }
        return result;
    }

    ///// Modifiers /////
    modifier onlyLatestVersion() {
       require(msg.sender == _latestVersion);
        _; // Fire the calling function here
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    ////// Owning contract's permissions ///////

    function paymentToken(address tokenContract) onlyOwner external {
        _paymentTokens.push(tokenContract);
    }

    function upgradeVersion(address newVersion) onlyOwner external {
        _latestVersion = newVersion;
    }

    function owner(address newOwner) onlyOwner external {
        _owner = newOwner;
    }

    function paymentAddress(address wallet) onlyOwner external {
        _paymentAddress = wallet;
    }

    // Set a new fee
    function fee(string calldata feeName, uint256 percentageInWei) onlyOwner external {
        _feeIndex.push(feeName);
        _fees[feeName] = percentageInWei;
    }

    ////////// *** Getter Methods *** //////////////

    function _ownerIndex(uint256 nftId, address wallet) internal view returns (uint){
        return _nftOwnersIndexes[nftId][wallet];
    }

    function isCurrentNftOwner(address wallet, uint256 nftId) public view returns (bool){
        bool result = false;
        if (_nftQuantities[nftId][_nftOwnersIndexes[nftId][wallet]] > 0){
            result = true;
        }
        return result;
    }

    function isPaymentToken(address tokenContract) public view returns (bool){
        bool result = false;
        uint i;
        for (i=0; i < _paymentTokens.length; i++){
            if (_paymentTokens[i] == tokenContract){
                result = true;
                break;
            }
        }
        return result;
    }
    function paymentTokens() public view returns (address[] memory){
        return _paymentTokens;
    }

    // Return array of all current fee names
    function fees() public view returns (string[] memory){
        return _feeIndex;
    }

    // Return the percentage in wei of the fee named `feeName`
    function fee(string calldata feeName) public view returns (uint256){
        return _fees[feeName];
    }

    function owner() external view returns (address){
        return _owner;
    }

    /*
     * return array of all historical owners plus the NFT creator's address at index zero
     */
    function nftOwners(uint256 nftId) public view returns (address[] memory){
        address[] memory wallets;
        //Skip the zero address
        uint i;
        for (i=1; i < _nftOwners[nftId].length; i++){
            wallets[i-1] = _nftOwners[nftId][i];
        }
        return wallets;
    }

    // Return just the NFT creator's address and the quantity created
    function nftCreator(uint256 nftId) public view returns (address, uint256){
        return (_nftOwners[nftId][0], _nftQuantities[nftId][0]);
    }

    /*
     * return array of all _current_ owners
     */
    function currentNftOwners(uint256 nftId) public view returns (address[] memory){
        address[] memory wallets;
        uint i;
        uint j = 0;
        // Skip the zero address
        for (i=1; i < _nftOwners[nftId].length; i++){
            if (_nftQuantities[nftId][i] > 0){
                wallets[j] = _nftOwners[nftId][i];
                j++;
            }
        }
        return wallets;
    }

    // Returns the nftRecord with creator and totalMinted at index zero of the ownersRecord
    function oneNftRecord(uint256 nftId) public view returns (address[] memory, uint256[] memory) {
        address[] memory wallets;
        uint256[] memory quantities;

        //Index zero is creator and total minted
        uint i;
        for (i=0; i < _nftOwners[nftId].length; i++){
            wallets[i] = _nftOwners[nftId][i];
            quantities[i] = _nftQuantities[nftId][i];
        }
        return (wallets, quantities);
    }

    function manyNftRecords(uint256[] calldata nftIds) public view returns (address[][] memory, uint256[][] memory){
        uint i;
        address[][] memory wallets;
        uint256[][] memory quantities;

        for (i=0; i < nftIds.length; i++){
            (wallets[i], quantities[i]) = oneNftRecord(nftIds[i]);
        }
        return (wallets, quantities);
    }

    function allNftRecords() external view returns (address[][] memory, uint256[][] memory){
        // cant convert storage to calldata, so write the code again :/
        uint i;
        address[][] memory wallets;
        uint256[][] memory quantities;

        for (i=0; i < _nftIds.length; i++){
            (wallets[i], quantities[i]) = oneNftRecord(_nftIds[i]);
        }
        return (wallets, quantities);
    }

    // *** Setter Methods ***
    function nftRecord(uint256 nftId, address creator, uint256 totalMinted) onlyLatestVersion external {
        _nftIds.push(nftId);
        pushOwnersRecord(nftId, creator, totalMinted);
        pushOwnersRecord(nftId, creator, totalMinted); //Twice to get it to the correct index
        _nftOwnersIndexes[nftId][creator] = 1; // its a new record and creator is first owner
    }

    // Assumes balances were verified... not safe
    function transferNft(uint256 nftId, address to, address from, uint256 quantity) onlyLatestVersion external {
        uint256[] storage quantities = _nftQuantities[nftId];

        quantities[_nftOwnersIndexes[nftId][from]] -= quantity;

        if (quantities[_nftOwnersIndexes[nftId][to]] != 0) {
            quantities[_nftOwnersIndexes[nftId][to]] += quantity;
        } else {
            // this is a new owner
            pushOwnersRecord(nftId, to, quantity);
            _nftOwnersIndexes[nftId][to] = quantities.length - 1; //record the index
        }
    }

    // *** Delete Methods ***
    function deleteFee(string calldata feename) onlyOwner external {
        // Safely compact the `_feeIndex`
        uint lastIndex = _feeIndex.length - 1;
        uint i;
        for (i=0; i < lastIndex - 1; i++){
            if (_isEqual(_feeIndex[i], feename)){
                // replace it with the last item
                _feeIndex[i] = _feeIndex[lastIndex];
                delete _feeIndex[lastIndex];
            }
        }
        // Now check the last item
        if (_isEqual(_feeIndex[lastIndex], feename)){
            delete _feeIndex[lastIndex];
        }
        delete _fees[feename];
    }

    function deleteNftRecord(uint256 nftId) onlyLatestVersion external {
        delete _nftOwners[nftId];
        delete _nftQuantities[nftId];
        uint i;
        for (i=0; i < _nftIds.length; i++){
            if (_nftIds[i] == nftId){
                //move the last element into its place
                _nftIds[i] = _nftIds[_nftIds.length - 1];
                delete _nftIds[_nftIds.length - 1];
            }
        }
    }
}