/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: TBD.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Minter for Dinos
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./access/MaxAccess.sol";
import "./modules/PaymentSplitterV2.sol";
import "./modules/Llamas.sol";
import "./eip/2981/ERC2981Collection.sol";

contract TwistedPickle is MaxAccess, PaymentSplitterV2, Llamas, ERC2981Collection, ERC721, ERC721Enumerable, ERC721Burnable {
  constructor() ERC721("Twisted Pickles", "TP") {}

  address[] private supportedContracts;
  uint256 private whitelistStart;
  uint256 private normalStart;
  uint256 private maxCap;
  string base;

  event UpdatedContract(address newContract, uint time);
  event UpdatedTimes(uint wlStart, uint normStart);
  event UpdatedBaseURI(string _old, string _new);

  error Unauthorized();

  function setTimes (
    uint wlStart
  ) external
    onlyDev() {
    uint normStart = wlStart + 2 days;
    whitelistStart = wlStart;
    normalStart = normStart;
    emit UpdatedTimes(whitelistStart, normalStart);
  }

  modifier whitelistTime() {
    uint meow = block.timestamp;
    if (meow < whitelistStart && normalStart <= meow) {
      revert Unauthorized();
    } 
    _;
  }

  modifier normalTime() {
    uint meow = block.timestamp;
    if (meow < normalStart) {
      revert Unauthorized();
    } 
    _;
  }

  modifier isActive() {
    if (whitelistStart == 0) {
      revert Unauthorized();
    }
    _;
  }

  function addCollab (
    address newContract
  ) external
    onlyDev() {
    supportedContracts.push(newContract);
    emit UpdatedContract(newContract, block.timestamp);
  }

  function addCollabs (
    address [] memory newContract
  ) external
    onlyDev() {
    uint max = newContract.length;
    for (uint x = 0; x < max;) {
      supportedContracts.push(newContract[x]);
      emit UpdatedContract(newContract[x], block.timestamp);
      unchecked { ++x; }
    }
  }

  function isCollab()
    internal 
    returns (bool) {
    IERC721 checkIt;
    uint owned;
    uint max = supportedContracts.length;
    for (uint x = 0; x < max;) {
      checkIt = IERC721(supportedContracts[x]);
      owned = checkIt.balanceOf(msg.sender);
      if (owned > 0) {
        return true;
      }
      unchecked { ++x; }      
    }
  }

  modifier collabOnly() {
    bool check = isCollab();
    if (!check) {
      revert Unauthorized();
    }
    _;
  }    

  function properID()
    internal
    view
    returns (uint) {
    return _nextUp() + 1;
  }

  function whitelistMint(
    uint quant
  ) external
    isActive()
    whitelistTime()
    collabOnly() {
    if (quant > 2) {
      revert Unauthorized();
    }
    for (uint x = 0; x < quant;) {
      _safeMint(msg.sender, properID());
      _oneRegularMint();
      unchecked { ++x; }
    }
  }

  function publicMint(
    uint quant
  ) external
    isActive()
    normalTime() {
    if (quant > 2) {
      revert Unauthorized();
    }
    for (uint x = 0; x < quant;) {
      _safeMint(msg.sender, properID());
      _oneRegularMint();
      unchecked { ++x; }
    }
  }
    

  // Function to receive ether, msg.data must be empty
  receive() external payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  // Function to receive ether, msg.data is not empty
  fallback() external payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  // @notice this is a public getter for ETH blance on contract
  function getBalance() external view returns (uint) {
    return address(this).balance;
  }

  // @notice will update _baseURI() by onlyDeveloper() role
  // @param _base: Base for NFT's
  function setBaseURI(
    string memory _base
    )
    public
    onlyDev() {
    string memory old = base;
    base = _base;
    emit UpdatedBaseURI(old, base);
  }

  /*   -*=+.          [email protected]*                          :=*#%%#-                                    
   * [email protected]@: #@.*@@%  .:#@@=                :     .*%%##@@=. :-                                   
   * .=-  @@%+#@* .=*@@-                [email protected]%.       [email protected]@-                                        
   *     +%@-:@@.:=-%@+ :#=          -+*@@%+.     [email protected]@+                     .#*                 
   *     *@+ *@#+#.#@%  +*           [email protected]@=       [email protected]@@=-.                   -#-                 
   *    =*@. @@@@::@@- .*:   =+: --   :@%      .%@@%+=-- -*= :-.   =##+%=  *+   .*- .-.  :+##- 
   *    #@=  [email protected]@. [email protected]#  #@=  :@@+*@@= [email protected]@.  :    [email protected]%    [email protected]@#[email protected]@+ :%%=.#@=:*@@  .%@*=%@# [email protected]@#@+ 
   *   [email protected]#        *@- [email protected]@:-=*@@#+%@:+#@* .++    [email protected]=  [email protected]%*@@%=%@[email protected]@#@[email protected]@@@@@=:-+%@%=#@[email protected]%*=.:=
   *    +-        [email protected] [email protected]@@*:%@- [email protected]@%-#@[email protected]#.    :@++%#- #@* :@@%+#%+-#@#= @@%%-#@#  @@%+**=#*= 
   *              -=- -=.  -+   --  .=+=:        ::.   :*   :=   .#@@%   .=:  .*:  .=.  .:.   
   *                                                             [email protected]*%@+                        
   *                                                            %@-:@@                         
   *                                                           [email protected]:.#@-                         
   *                                                          +%*@%:                          
   *
   * @dev: This is the internal -> external functions for the mint engine Llamas.sol (PsuedoRand)
   */

  function toggleStart()
    external
    onlyDev() {
    _setStatus(true);
  }

  function toggleStop()
    external
    onlyDev() {
    _setStatus(false);
  }

  function setMintPrice (
    uint _inToken
  ) external
    onlyDev() {
    _setMintFees(_inToken * 10**18);
  }

  function setMintPriceWei (
    uint _inWei
  ) external
    onlyDev() {
    _setMintFees(_inWei);
  }

  function setTeamMax (
    uint number
  ) external
    onlyDev() {
    _setMintLimitTeam(number);
  }

  function setMaxMint (
    uint number
  ) external
    onlyDev() {
    _setMintLimit(number);
  }

  function setProvenances (
    string memory IMG
  , string memory JSON
  ) external
    onlyDev() {
    _setProvenance(IMG, JSON);
  }


  /*      :==++-   :-==+*#+ .*%++*-  :-:                                                       
   * :+*%%@@%-::=.*#%@#--: *@#   @@-*=:@%                  =#%%*=-.    =*++=%#   -#%*=:    .#@#
   * -: [email protected]@.       @@:   *@@   [email protected]@#+  @@:               [email protected]@#:   [email protected]  *@%[email protected]@+  *@@[email protected] [email protected]@@*
   *    [email protected]@:       *@*   [email protected]@+   +*@+  *@%               #@%=     [email protected] *@+ [email protected]@+  +%#  **# .%%@@@ 
   *   [email protected]@+:.     :@@    [email protected]@+   +%#  [email protected]@.               .:      [email protected]# [email protected]#=*%@+   [email protected] [email protected]%    -%@+ 
   * =%@@#*++.    #@:     %@@  :[email protected] [email protected]@:.#####%%##*#%-         +%=   :+*@@*     .=*@#     %%%  
   *  *@*    -   [email protected]       .:   *+.+*=                       :*=       [email protected]@.     :+  +#.  -%@-  
   *  @@:  [email protected]+   %%.          :.*                           -+.  .     #@#    #%+   *@-  +%@   
   *  *@[email protected]*.  -*@%*=         =*-                         +#%*#%%@-    #@-    ##-=+++=  -%@@#. 
   *
   * @dev: This is the internal -> external functions for ERC2981Collection.sol
   */

  function erc2981This (
    uint permille
  ) external
    onlyDev() {
    _setRoyalties(address(this), permille);
  }

  function setRoyalties (
    address newAddress
  , uint256 permille
  ) external
    onlyDev() {
    _setRoyalties(newAddress, permille);
  }

  function clearRoyalties()
    external
    onlyDev() {
    _removeRoyalties();
  }

  /*  .+%+-#- :==.             .=*#**:                                        =*:    .=:  ..   
   * :@%.  @@*= @@           +%@#[email protected]@-         .**-      -    -                [email protected]*   =*:-%@#==+:
   * %@-  :%@= :@@         .%@+.  :.         :@*+.:.   *@*= *@*=              [email protected]*  ++:#@*.   [email protected]
   * @@.  +** .%@:         :@-              .%#[email protected]:.#@@*-#@@*:               :@% *# -+:    [email protected]*
   * #@= .-% .%@-           .---:-+-#@ -+%* %@+: =.   %%   %@  .++: =% [email protected]=     @@+*.       -%= 
   *  :. .*+:*=.             .-*@+ [email protected]%*[email protected]#*@#. [email protected]=  [email protected]  *@- [email protected]%%# @#+-:+.    [email protected]*=       ++   
   *    ..*      =+.       :**: @# %@%=*@#:[email protected]:.+%@:[email protected]% -*@% [email protected]*=--*@@=        :@%      :=:..: 
   *    =#-     .**:     =%*.:[email protected]%[email protected]# #@#  [email protected]##-#@#[email protected]###[email protected]###++**:#@=          #%     #%%#**+.
   *     :.              :**++=: :%%                  .    .        .                          
   *                             #@:                                                           
   *
   * @dev: This is the internal -> external functions for PaymentSplitterV2.sol
   */

  function addSplit (
    address newSplit
  , uint256 newShares
  ) external
    onlyDev() {
    _addPayee(newSplit, newShares);
  }

  function removeSplit (
    address remSplit
  ) external
    onlyDev() {
    _removePayee(remSplit);
  }

  function clearSplits()
    external
    onlyDev() {
    _clearAll();
  }

  // The following functions are overrides required by Solidity.
  function _baseURI() internal view override returns (string memory) {
    return base;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(MaxAccess, Llamas, ERC2981Collection, ERC721, ERC721Enumerable)
    returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: PaymentSplitterV2.sol
 * @author: OG was OZ, rewritten by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Updated to add/subtract payees
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
// Removal of SafeMath due to ^0.8.0 standards, not needed

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */

abstract contract PaymentSplitterV2 {

  event PayeeAdded(address account, uint256 shares);
  event PaymentReleased(address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);
  event PayeeRemoved(address account, uint256 shares);
  event PayeesReset();

  error PaymentSplitterV2Error(string _reason);

  uint256 private _totalShares;
  uint256 private _totalReleased;
  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  /**
   * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
   * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
   * reliability of the events, and not the actual splitting of Ether.
   *
   * To learn more about this see the Solidity documentation for
   * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
   * functions].
   *
   *  receive() external payable virtual {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   *  // Fallback function is called when msg.data is not empty
   *  // Added to PaymentSplitter.sol
   *  fallback() external payable {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   * receive() and fallback() to be handled at final contract
   */

  /**
   * @dev Getter for the total shares held by payees.
   */
  function totalShares() external view returns (uint256) {
    return _totalShares;
  }

  /**
   * @dev Getter for the total amount of Ether already released.
   */
  function totalReleased() external view returns (uint256) {
    return _totalReleased;
  }

  /**
   * @dev Getter for the amount of shares held by an account.
   */
  function shares(address account) external view returns (uint256) {
    return _shares[account];
  }

  /**
   * @dev Getter for the amount of Ether already released to a payee.
   */
  function released(address account) external view returns (uint256) {
    return _released[account];
  }

  /**
   * @dev Getter for the address of the payee number `index`.
   */
  function payee(uint256 index) external view returns (address) {
    return _payees[index];
  }

  /**
   * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
   * total shares and their previous withdrawals.
   */
  // This function was updated from "account" to msg.sender
  function claim() external virtual {
    address check = msg.sender;

    if (_shares[check] == 0) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: You have no shares"
      });
    }

    uint256 totalReceived = address(this).balance + _totalReleased;
    uint256 payment = (totalReceived * _shares[check]) / _totalShares - _released[check];

    if (payment == 0) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: You are not due payment"
      });
    }

    _released[check] = _released[check] + payment;
    _totalReleased = _totalReleased + payment;

    Address.sendValue(payable(check), payment);
    emit PaymentReleased(check, payment);
  }

  /**
   * @dev Add a new payee to the contract.
   * @param account The address of the payee to add.
   * @param shares_ The number of shares owned by the payee.
   */
  // This function was updated to internal
  function _addPayee(address account, uint256 shares_) internal {
    if (account == address(0)) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: account is the zero address"
      });
    } else if (shares_ == 0) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: shares are 0"
      });
    } else if (_shares[account] > 0) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: account already has shares"
      });
    }

    _payees.push(account);
    _shares[account] = shares_;
    _totalShares = _totalShares + shares_;

    emit PayeeAdded(account, shares_);
  }

  /**
   * @dev finds index in array
   * @param account The address of the payee
   */
  function _findIndex(address account) internal view returns (uint index) {
    uint max = _payees.length;
    for (uint i = 0; i < max;) {
      if (_payees[i] == account) {
        index = i;
      }
      unchecked { ++i; }
    }
  }

  /**
   * @dev Remove a payee to the contract.
   * @param account The address of the payee to remove.
   * leaves all payment data in the contract incase something was claimed
   */
  function _removePayee(address account) internal {
    if (account == address(0)) {
      revert PaymentSplitterV2Error({
        _reason: "PaymentSplitter: account is the zero address"
      });
    } 

    // This finds the payee in the array _payees and removes it
    uint remove = _findIndex(account);
    address last = _payees[_payees.length - 1];
    _payees[remove] = last;
    _payees.pop();

    uint removeTwo = _shares[account];
    _shares[account] = 0;
    _totalShares = _totalShares - removeTwo;

    emit PayeeRemoved(account, removeTwo);
  }

  /**
   * @dev clears all data in PaymentSplitterV2
   * leaves all payment data in the contract incase something was claimed
   */
  function _clearAll() internal {
    uint max = _payees.length;
    for (uint i = 0; i < max;) {
      address account = _payees[i];
      _shares[account] = 0;
      unchecked { ++i; }
    }
    delete _totalShares;
    delete _payees;
    emit PayeesReset();
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Llamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Solidity for Llama/BAYC Mint engine, does Provenance for Metadata/Images
 * Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ILlamas.sol";
import "./IMAX721.sol";
import "../lib/PsuedoRand.sol";

abstract contract Llamas is IMAX721, ILlamas {

  using PsuedoRand for PsuedoRand.Engine;

  PsuedoRand.Engine private llamas;

  // @dev this is for any team mint that happens, must be included in mint...
  function _oneTeamMint()
    internal {
    llamas.battersUp();
    llamas.battersUpTeam();
  }

  // @dev this is for any mint outside of a team mint, must be included in mint...
  function _oneRegularMint()
    internal {
    llamas.battersUp();
  }

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function _setStatus(
    bool toggle
  ) internal {
    llamas.setStatus(toggle);
  }

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function _setMintFees(
    uint number
  ) internal {
    llamas.setFees(number);
  }

  // @dev this will set the minter capacity of team mints
  // @param number: uint for maximum, 10,000 for 10k i.e.
  function _setMintLimitTeam(
    uint number
  ) internal {
    llamas.setMaxTeam(number);
  }

  // @dev this will set the minter capacity
  // @param number: uint for maximum, 10,000 for 10k i.e.
  // @notice: This is a prereq to _setPovenance(string, string)
  function _setMintLimit(
    uint number
  ) internal {
    llamas.setMaxCap(number);
  }

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function _setProvenance(
    string memory img
  , string memory json
  ) internal {
    llamas.setProvJSON(json);
    llamas.setProvIMG(img);
    llamas.setStartNumber();
  }

  function _nextUp()
    internal
    view
    returns (uint) {
    return llamas.mintID();
  }

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus()
    external
    view
    override(IMAX721)
    returns (bool) {
    return llamas.status;
  }

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    override(IMAX721)
    returns (uint) {
    return llamas.mintFee;
  }

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMaximumCapacity()
    external
    view
    override(IMAX721)
    returns (uint) {
    return llamas.maxCapacity;
  }

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterMaximumTeamMints()
    external
    view
    override(IMAX721)
    returns (uint) {
    return llamas.maxTeamMints;
  }

  // @dev will return "team mints" left
  // @return - uint of remaing airdrops or team mints
  function minterTeamMintsRemaining()
    external
    view
    override(IMAX721)
    returns (uint) {
    return llamas.maxTeamMints - llamas.showTeam();
  }

  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsCount()
    external
    view
    override(IMAX721)
    returns (uint) {
    return llamas.showTeam();
  }

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages() 
    external 
    view 
    override(ILlamas) 
    returns (string memory) {
    return llamas.ProvenanceIMG;
  }

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    override(ILlamas)
    returns (string memory) {
    return llamas.ProvenanceJSON;
  }

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartNumber()
    external
    view
    override(ILlamas)
    returns (uint256) {
    return llamas.startNumber;
  }

  // @notice solidity required override for supportsInterface(bytes4)
  // @param bytes4 interfaceId - bytes4 id per interface or contract
  function supportsInterface(
    bytes4 interfaceId
  ) public
    view
    virtual
    override(IERC165)
    returns (bool) {
    return (
      interfaceId == type(ILlamas).interfaceId  ||
      interfaceId == type(IMAX721).interfaceId
    );
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IMAX721.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for UX/UI
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

///
/// @dev Interface for @MaxFlowO2's Contracts
///

interface IMAX721 is IERC165 {

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus() 
    external
    view
    returns (bool);

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    returns (uint);

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMaximumCapacity()
    external
    view
    returns (uint);

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterMaximumTeamMints()
    external
    view
    returns (uint);

  // @dev will return "team mints" left
  // @return - uint of remaing airdrops or team mints
  function minterTeamMintsRemaining()
    external
    returns (uint);

  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsCount()
    external
    returns (uint);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Llamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for Llama/BAYC Mint engine, does Provenance for Metadata/Images
 * Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

///
/// @dev Interface for the ILlamas Standard v2.0
///  this includes metadata with images
///

interface ILlamas is IERC165{

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages()
    external
    view
    returns (string memory);

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    returns (string memory);

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartNumber()
    external
    view
    returns (uint256);

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Roles.sol
 * @author: OpenZeppelin, rewrite by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Library for MaxAcess.sol
 * @dev: Rewritten for gas optimization, and from abstract -> library, added
 * multiple types instead of a solo role.
 * Original source:
 * https://github.com/hiddentao/openzeppelin-solidity/blob/master/contracts/access/Roles.sol
 *
 * Include with 'using Roles for Roles.Role;'
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library Roles {

  event RoleGranted(bytes4 _type, address _user); // 0x0baaa7ab
  event RoleRevoked(bytes4 _type, address _user); // 0x6107a4a5
  error Unauthorized(); // 0x82b42900
  error RolesError(string _error); // 0x08c379a0

  struct Role {
    mapping(address => mapping(bytes4 => bool)) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, bytes4 _type, address account) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (has(role, _type, account)) {
      revert RolesError({
        _error: "User already has this role"
      });
    }
    role.bearer[account][_type] = true;
    emit RoleGranted(_type, account);
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, bytes4 _type, address account) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (!has(role, _type, account)) {
      revert RolesError({
        _error: "User does not have this role"
      });
    }
    role.bearer[account][_type] = false;
    emit RoleRevoked(_type, account);
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, bytes4 _type, address account)
    internal
    view
    returns (bool)
  {
    if (account == address(0)) {
      revert Unauthorized();
    }
    return role.bearer[account][_type];
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: PsuedoRand.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Library for Llama/BAYC Mint engine...
 *  basically a random start point and a bookends mint to start
 *  i.e. 0-2999 start at 500 -> 2999, then 0 -> 499.
 *
 *  Covers IMAX721.sol and Illamas.sol
 *
 * Include with 'using PsuedoRand for PsuedoRand.Engine;'
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library PsuedoRand {

  using CountersV2 for CountersV2.Counter;

  event SetProvenanceIMG(string _new, string _old);
  event SetProvenanceJSON(string _new, string _old);
  event SetStartNumber(uint _new);
  event SetMaxCapacity(uint _new, uint _old);
  event SetMaxTeamMint(uint _new, uint _old);
  event SetMintFees(uint _new, uint _old);
  event SetStatus(bool _new);

  error PsuedoRandError(string _reason);

  struct Engine {
    uint256 mintFee;
    uint256 startNumber;
    uint256 maxCapacity;
    uint256 maxTeamMints;
    string ProvenanceIMG;
    string ProvenanceJSON;
    CountersV2.Counter currentMinted;
    CountersV2.Counter currentTeam;
    bool status;
  }

  function setProvJSON(
    Engine storage engine
  , string memory provJSON
  ) internal {
    string memory old = engine.ProvenanceJSON;
    engine.ProvenanceJSON = provJSON;
    emit SetProvenanceJSON(provJSON, old);
  }
 
  function setProvIMG(
    Engine storage engine
  , string memory provIMG
  ) internal {
    string memory old = engine.ProvenanceIMG;
    engine.ProvenanceIMG = provIMG;
    emit SetProvenanceIMG(provIMG, old);
  }

  function setStartNumber(
    Engine storage engine
  ) internal {
    if (engine.maxCapacity == 0) {
      revert PsuedoRandError({
        _reason : "PsuedoRandom Lib: Maximum Capacity not set!"
      });
    }
    engine.startNumber = uint(
                           keccak256(
                             abi.encodePacked(
                               block.timestamp
                             , msg.sender
                             , engine.ProvenanceIMG
                             , engine.ProvenanceJSON
                             , block.difficulty))) 
                         % engine.maxCapacity;
    emit SetStartNumber(engine.startNumber);
  }

  function setMaxCap(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxCapacity;
    engine.maxCapacity = max;
    emit SetMaxCapacity(max, old);
  }

  function setMaxTeam(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxTeamMints;
    engine.maxTeamMints = max;
    emit SetMaxTeamMint(max, old);
  }

  function setFees(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.mintFee;
    engine.mintFee = max;
    emit SetMintFees(max, old);
  }

  function setStatus(
    Engine storage engine
  , bool change
  ) internal {
    engine.status = change;
    emit SetStatus(change);
  }

  function mintID(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return (engine.startNumber + engine.currentMinted.current()) % engine.maxCapacity;
  }

  function showTeam(
    Engine storage engine
  ) internal 
    view
    returns (uint256) {
    return engine.currentTeam.current();
  }

  function showMinted(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.currentMinted.current();
  }

  function battersUpTeam(
    Engine storage engine
  ) internal {
    engine.currentTeam.increment();
  }

  function battersUp(
    Engine storage engine
  ) internal {
    engine.currentMinted.increment();
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: CountersV2.sol
 * @author Matt Condon (@shrugs), Edits by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Provides counters that can only be incremented, decremented, reset or set. 
 * This can be used e.g. to track the number of elements in a mapping, issuing ERC721 ids
 * or counting request ids.
 *
 * Edited by @MaxFlowO2 for more NFT functionality on 13 Jan 2022
 * added .set(uint) so if projects need to start at say 1 or some random number they can
 * and an event log for numbers being reset or set.
 *
 * Include with `using CountersV2 for CountersV2.Counter;`
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library CountersV2 {

  error CountersV2Error(string _reason);

  event CounterNumberChangedTo(uint _number);

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
      ++counter._value;
    }
  }

  function decrement(Counter storage counter) internal {
    uint256 value = counter._value;
    if (value == 0) {
      revert CountersV2Error({
        _reason : "CountersV2: No negatives in uints"
      });
    }
    unchecked {
      --counter._value;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
    emit CounterNumberChangedTo(counter._value);
  }

  function set(Counter storage counter, uint number) internal {
    counter._value = number;
    emit CounterNumberChangedTo(counter._value);
  }  
}

/***
 *    ███████╗██╗██████╗       ██████╗  █████╗  █████╗  ██╗
 *    ██╔════╝██║██╔══██╗      ╚════██╗██╔══██╗██╔══██╗███║
 *    █████╗  ██║██████╔╝█████╗ █████╔╝╚██████║╚█████╔╝╚██║
 *    ██╔══╝  ██║██╔═══╝ ╚════╝██╔═══╝  ╚═══██║██╔══██╗ ██║
 *    ███████╗██║██║           ███████╗ █████╔╝╚█████╔╝ ██║
 *    ╚══════╝╚═╝╚═╝           ╚══════╝ ╚════╝  ╚════╝  ╚═╝                                                        
 * Zach Burks, James Morgan, Blaine Malone, James Seibel,
 * "EIP-2981: NFT Royalty Standard,"
 * Ethereum Improvement Proposals, no. 2981, September 2020. [Online serial].
 * Available: https://eips.ethereum.org/EIPS/eip-2981.
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///

interface IERC2981 is IERC165 {

  // @notice Called with the sale price to determine how much royalty
  //  is owed and to whom.
  // @param _tokenId - the NFT asset queried for royalty information
  // @param _salePrice - the sale price of the NFT asset specified by _tokenId
  // @return receiver - address of who should be sent the royalty payment
  // @return royaltyAmount - the royalty payment amount for _salePrice
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    returns (
    address receiver
  , uint256 royaltyAmount
  );
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC2981Collection.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Use case for EIP 2981, steered more towards NFT Collections as a whole
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IERC2981.sol";

abstract contract ERC2981Collection is IERC2981 {

  address private royaltyAddress;
  uint256 private royaltyPermille;

  event royalatiesSet(
          uint value
        , address recipient);
  error UnauthorizedERC2981();

  // @dev to set roaylties on contract via EIP 2891
  // @param _receiver, address of recipient
  // @param _permille, permille xx.x -> xxx value
  function _setRoyalties(
    address _receiver
  , uint256 _permille
  ) internal {
  if (_permille > 1001 || _permille == 0) {
    revert UnauthorizedERC2981();
  }
    royaltyAddress = _receiver;
    royaltyPermille = _permille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @dev to remove royalties from contract
  function _removeRoyalties() internal {
    delete royaltyAddress;
    delete royaltyPermille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @dev Override for royaltyInfo(uint256, uint256)
  // @param _tokenId, uint of token ID to be checked
  // @param _salePrice, uint of amount of sale
  // @return receiver, address of recipient
  // @return royaltyAmount, amount royalties recieved
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    override(IERC2981)
    returns (
    address receiver
  , uint256 royaltyAmount
  ) {
    receiver = royaltyAddress;
    royaltyAmount = _salePrice * royaltyPermille / 1000;
  }

  // @dev solidity required override for supportsInterface(bytes4)
  // @param bytes4 interfaceId - bytes4 id per interface or contract
  function supportsInterface(
    bytes4 interfaceId
  ) public
    view
    virtual
    override(IERC165)
    returns (bool) {
    return (
      interfaceId == type(IERC2981).interfaceId
    );
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: MaxAccess.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Access control based off EIP 173/roles from OZ
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IOwner.sol";
import "./IDeveloper.sol";
import "../lib/Roles.sol";

abstract contract MaxAccess is IOwner, IDeveloper {
  using Roles for Roles.Role;

  Roles.Role private contractRoles;

  bytes4 constant private DEVS = 0xca4b208b; // ERC165 calc of developer()
  bytes4 constant private PENDING_DEVS = 0xca4b208c; // DEVS++
  bytes4 constant private OWNERS = 0x8da5cb5b; // ERC165 calc of owner()
  bytes4 constant private PENDING_OWNERS = 0x8da5cb5c; // OWNER++

  error UnauthorizedAccess();

  constructor() {
    init();
  }

  // @dev: initial setting for MaxAccess
  function init() internal {
    contractRoles.add(OWNERS, msg.sender);
    contractRoles.add(DEVS, msg.sender);
  }

  // @dev: returns if owner or not
  // @param _user: address
  // @return: bool
  function owner(
    address _user
  ) external
    view
    virtual
    override(IOwner)
    returns (bool) {
    return contractRoles.has(OWNERS, _user);
  }

  modifier onlyOwner() {
    bool check = contractRoles.has(OWNERS, msg.sender);
    if (!check) {
      revert UnauthorizedAccess();
    }
    _;
  }

  // @dev: renounces ownership
  // @notice: only renounces one owner not all
  function renounceOwner()
    external
    virtual
    override(IOwner)
    onlyOwner() {
    contractRoles.remove(OWNERS, msg.sender);
  }

  // @dev: adds a new pending owner role
  // @param newOwner: address of another pending owner
  // @notice: does not revoke any roles makes more pending owners
  function transferOwner(
    address newOwner
  ) external
    override(IOwner)
    onlyOwner() {
    contractRoles.add(PENDING_OWNERS, newOwner);
  }

  // @dev: accepts pending owner and makes an owner
  // @notice: revokes pending owner and add owner role
  function acceptOwner()
    external
    virtual
    override(IOwner) {
    if (!contractRoles.has(PENDING_OWNERS, msg.sender)) {
      revert UnauthorizedAccess();
    }
    contractRoles.remove(PENDING_OWNERS, msg.sender);
    contractRoles.add(OWNERS, msg.sender);
  }

  // @dev: declines pending owner role
  // @notice: revokes pending owner role
  function declineOwner()
    external
    virtual
    override(IOwner) {
    if (!contractRoles.has(PENDING_OWNERS, msg.sender)) {
      revert UnauthorizedAccess();
    }
    contractRoles.remove(PENDING_OWNERS, msg.sender);
  }

  // @dev: directly sets owner role to others
  // @param newOwner: address of another owner
  // @notice: add to roles never takes away
  function pushOwner(
    address newOwner
  ) external
    virtual
    override(IOwner)
    onlyOwner() {
    contractRoles.add(OWNERS, newOwner);
  }

  // @dev: returns if developer or not
  // @param _user: address
  // @return: bool
  function developer(
    address _user
  ) external
    view
    virtual
    override(IDeveloper)
    returns (bool) {
    return contractRoles.has(DEVS, _user);
  }

  modifier onlyDev() {
    bool check = contractRoles.has(DEVS, msg.sender);
    if (!check) {
      revert UnauthorizedAccess();
    }
    _;
  }

  // @dev: renounces developer
  // @notice: only renounces one developer not all
  function renounceDeveloper()
    external
    virtual
    override(IDeveloper)
    onlyDev() {
    contractRoles.remove(DEVS, msg.sender);
  }

  // @dev: adds a new pending developer role
  // @param newDeveloper: address of another pending developer
  // @notice: does not revoke any roles makes more pending developers
  function transferDeveloper(
    address newDeveloper
  ) external
    virtual
    override(IDeveloper)
    onlyDev() {
    contractRoles.add(PENDING_DEVS, newDeveloper);
  }

  // @dev: accepts pending developer and makes an developer
  // @notice: revokes pending developer and add developer role
  function acceptDeveloper()
    external
    virtual
    override(IDeveloper) {
    if (!contractRoles.has(PENDING_DEVS, msg.sender)) {
      revert UnauthorizedAccess();
    }
    contractRoles.remove(PENDING_DEVS, msg.sender);
    contractRoles.add(DEVS, msg.sender);
  }

  // @dev: declines pending developer role
  // @notice: revokes pending developer role
  function declineDeveloper()
    external
    virtual
    override(IDeveloper) {
    if (!contractRoles.has(PENDING_DEVS, msg.sender)) {
      revert UnauthorizedAccess();
    }
    contractRoles.remove(PENDING_DEVS, msg.sender);
  }

  // @dev: directly sets developer role to others
  // @param newDeveloper: address of another developer
  // @notice: add to roles never takes away
  function pushDeveloper(
    address newDeveloper
  ) external
    virtual
    override(IDeveloper)
    onlyDev() {
    contractRoles.add(DEVS, newDeveloper);
  }

  // @dev solidity required override for supportsInterface(bytes4)
  // @param bytes4 interfaceId - bytes4 id per interface or contract
  function supportsInterface(
    bytes4 interfaceId
  ) public
    view
    virtual
    override(IERC165)
    returns (bool) {
    return (
      interfaceId == type(IOwner).interfaceId  ||
      interfaceId == type(IDeveloper).interfaceId
    );
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title: IOwner.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for onlyOwner() role
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IOwner is IERC165 {

  function owner(address user) external view returns (bool);
  function renounceOwner() external;
  function transferOwner(address newOwner) external;
  function acceptOwner() external;
  function declineOwner() external;
  function pushOwner(address newOwner) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title: IDeveloper.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for onlyDev() role
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IDeveloper is IERC165 {

  function developer(address user) external view returns (bool);
  function renounceDeveloper() external;
  function transferDeveloper(address newDeveloper) external;
  function acceptDeveloper() external;
  function declineDeveloper() external;
  function pushDeveloper(address newDeveloper) external;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Metadata.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
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
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
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
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
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
}