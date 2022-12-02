// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./interfaces/ITheDotPayBank.sol";
import "./interfaces/IMerchant.sol";
import "./Merchant.sol";

/// @title TheDotPayBank Contract
/// @author Ram Krishan Pandey
/// @dev This Contract is governed by TheDotPayBank owner
contract TheDotPayBank is ITheDotPayBank, Context {
    //State-Variables

    ///@dev _theDotPayBankOwner is address type private state variable which stores the value of the dotpay bank owner address.
    ///@notice _theDotPayBankOwner is initilized at the time of constructor function call.
    address private _theDotPayBankOwner;

    ///@dev _verifiersData is mapping type private state variable which stores the value of the verifiers.
    ///@notice _verifiersData is a private state variable.
    mapping(address => verifierDetails) private _verifiersData;

    ///@dev _verifiersList is array type private state variable which stores the value of address the verifiers.
    ///@notice _verifiersList is a private state variable.
    address[] private _verifiersList;

    ///@dev _merchantsContractAddressFromUid is mapping type private state variable which stores the value of the uid and merchant`s contract address.
    ///@notice _merchantsContractAddressFromUid is a private state variable.
    mapping(string => address) private _merchantsContractAddressFromUid;

    ///@dev _merchantsList is array type private state variable which stores the value of the merchant`s contract address list.
    ///@notice _merchantsList is a private state variable.
    address[] private _merchantsList;

    ///@dev _transactionsFromMerchants is array type private state variable which stores the value of the merchant`s transaction.
    ///@notice _transactionsFromMerchants is a private state variable.
    mapping(address => transactionDetails[]) private _transactionsFromMerchants;

    //Errors
    ///@dev UnauthorisedAccess is an Error which occures when a requireCallerAddress_ is not equal to requesterCallerAddress_.
    ///@notice UnauthorisedAccess emits requireCallerAddress_ ,requesterCallerAddress_ and reason_.
    error UnauthorisedAccess(
        address requireCallerAddress_,
        address requesterCallerAddress_,
        string reason_
    );

    ///@dev InSufficientBalanceError is an Error which occures when availableBalance_ is less than requestedAmount_.
    ///@notice InSufficientBalanceError emits availableBalance_ ,requestedAmount_ and reason_.
    error InSufficientBalanceError(
        uint256 availableBalance_,
        uint256 requestedAmount_,
        string reason_
    );

    ///@dev UnExpectedSharePercentage is an Error which occures when sharingCliffValue_ is less than requestedSharingValue_.
    ///@notice UnExpectedSharePercentage emits sharingCliffValue_, requestedSharingValue_ and reason_.
    error UnExpectedSharePercentage(
        uint256 sharingCliffValue_,
        uint256 requestedSharingValue_,
        string reason_
    );

    ///@dev InSufficientAllowanceError is an Error which occures when availableAllowance_ is less than requestedAllowance_.
    ///@notice InSufficientAllowanceError emits availableAllowance_ ,requestedAllowance_ and reason_.
    error InSufficientAllowanceError(
        uint256 availableAllowance_,
        uint256 requestedAllowance_,
        string reason_
    );

    ///@dev UnExpectedShare is an Error which occures when an given share percentage is 0.
    ///@notice UnExpectedShare emits requestedSharingValue_ and reason_.
    error UnExpectedShare(uint256 requestedSharingValue_, string reason_);

    ///@dev UnExpectedAddress is an Error which occures when an given address is address(0).
    ///@notice UnExpectedAddress emits requestedAddressValue_ and reason_.
    error UnExpectedAddress(address requestedAddressValue_, string reason_);

    ///@dev UnExpectedVerifiersAddress is an Error which occures when an unexpected verifiers address is given.
    ///@notice UnExpectedVerifiersAddress emits verifierAddress_ and reason_.
    error UnExpectedVerifiersAddress(address verifierAddress_, string reason_);

    ///@dev MerchantAlreadyExists is an Error which occures when an merchant already exists.
    ///@notice MerchantAlreadyExists emits merchantContractAddress_, uid_ and reason_.
    error MerchantAlreadyExists(
        address merchantContractAddress_,
        string uid_,
        string reason_
    );

    //Modifiers
    ///@dev isTheDotPayBankOwner modifier checks that transaction signer is _theDotPayBankOwner owner else returns UnauthorisedAccess Error.
    modifier isTheDotPayBankOwner() {
        if (_msgSender() != _theDotPayBankOwner)
            revert UnauthorisedAccess(
                _theDotPayBankOwner,
                _msgSender(),
                "Only _theDotPayBankOwner can call this function"
            );
        _;
    }

    ///@dev isVerifier modifier checks that transaction signer is Verifier owner else returns UnauthorisedAccess Error.
    modifier isVerifier() {
        if (_verifiersData[_msgSender()].timeStamp == 0)
            revert UnauthorisedAccess(
                address(0),
                _msgSender(),
                "Only Verifier can call this function"
            );
        if (_verifiersData[_msgSender()].isBlocked == true)
            revert UnauthorisedAccess(
                address(0),
                _msgSender(),
                "Your verifiers account is blocked"
            );
        _;
    }

    //Events

    ///@dev AddMerchant occurs emiting merchantContractAddress ,verifierAddress_ and timeStamp_  when a new merchant is added.
    event AddMerchant(
        address indexed merchantContractAddress,
        address indexed verifierAddress_,
        uint256 indexed timeStamp_
    );

    ///@dev BlockMerchant occurs emiting merchantContractAddress_, verifier_ and timeStamp_  when the merchant is blocked.
    event BlockMerchant(
        address indexed merchantContractAddress_,
        address indexed verifier_,
        uint256 indexed timeStamp_
    );

    ///@dev UnBlockMerchant occurs emiting merchantContractAddress_, verifier_ and timeStamp_  when the merchant is unblocked.
    event UnBlockMerchant(
        address indexed merchantContractAddress_,
        address indexed verifier_,
        uint256 indexed timeStamp_
    );

    ///@dev SetCurrentShareMerchant occurs emiting merchantContractAddress_, newShare_, verifier_ and timeStamp_ when the share of merchant is updated.
    event SetCurrentShareMerchant(
        address indexed merchantContractAddress_,
        uint256 indexed newShare_,
        address indexed verifier_,
        uint256 timeStamp_
    );

    ///@dev SetCurrentBusinessCategoryMerchant occurs emiting oldBusinessCategory_, newBusinessCategory_ and timeStamp_ when the business name of merchant is changes.
    event SetCurrentBusinessCategoryMerchant(
        string indexed oldBusinessCategory_,
        string indexed newBusinessCategory_,
        uint256 indexed timeStamp_
    );

    ///@dev AddVerifier occurs emiting verifierAddress_, by_ and timeStamp_ of whne a new verifier is added.
    event AddVerifier(
        address indexed verifierAddress_,
        address indexed by_,
        uint256 indexed timeStamp_
    );

    ///@dev BlockVerifier occurs emiting verifierAddress_, by_ and timeStamp_ when the verifier is blocked.
    event BlockVerifier(
        address indexed verifierAddress_,
        address indexed by_,
        uint256 indexed timeStamp_
    );

    ///@dev WithdrawBNB occurs emiting amount_, by_ and timeStamp_ when the BNB is withdraw from contract.
    event WithdrawBNB(
        uint256 indexed amount_,
        address indexed by_,
        uint256 indexed timeStamp_
    );

    ///@dev WithdrawTokens occurs emiting tokenAddress_ ,amount_, by_ and timeStamp_  when the tokens are withdraw from contract.
    event WithdrawTokens(
        address indexed tokenAddress_,
        uint256 indexed amount_,
        address indexed by_,
        uint256 timeStamp_
    );

    ///@dev TransferOwnerShip occurs emiting oldOwnerAddress_, newOwnerAddress_ and timeStamp_ when the ownership is transfered.
    event TransferOwnerShip(
        address indexed oldOwnerAddress_,
        address indexed newOwnerAddress_,
        uint256 indexed timeStamp_
    );

    ///@dev PayWithToken occurs emiting merchantContractAddress_, amount_, tokenAddress_  and timeStamp_ when the payment is done through tokens.
    event PayWithToken(
        address indexed merchantContractAddress_,
        uint256 indexed amount_,
        address indexed tokenAddress_,
        uint256 timeStamp_
    );

    ///@dev PayWithBNB occurs emiting merchantContractAddress_, amount_ and timeStamp_ when the payment is done through BNB.
    event PayWithBNB(
        address indexed merchantContractAddress_,
        uint256 indexed amount_,
        uint256 indexed timeStamp_
    );

    ///@dev initialize state variable _theDotPayBankOwner.
    constructor(address owner_) {
        _theDotPayBankOwner = owner_;
    }

    ///@dev getTheDotPayBankDetails is a view function which returns the address of the dot pay contract and _theDotPayBankOwner.
    function getTheDotPayBankDetails()
        external
        view
        returns (address theDotPayBankAddress, address theDotPayBankOwner)
    {
        theDotPayBankAddress = address(this);
        theDotPayBankOwner = _theDotPayBankOwner;
    }

    ///@dev getBNBBalance is a view function which returns the BNB balance of the contract.
    function getBNBBalance() external view returns (uint256) {
        return (address(this).balance);
    }

    ///@dev getTokenBalance is a view function which returns the given token balance of the contract.
    function getTokenBalance(address tokenAddress_)
        external
        view
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress_);
        return (token.balanceOf(address(this)));
    }

    ///@dev getVerifiersList is a view function which returns the verifiers list.
    function getVerifiersList() external view returns (address[] memory) {
        return (_verifiersList);
    }

    ///@dev getVerifierDetails is a view function which returns the verifiers details.
    function getVerifierDetails(address verifierAddress_)
        public
        view
        returns (verifierDetails memory)
    {
        return (_verifiersData[verifierAddress_]);
    }

    ///@dev getAllVerifierDetails is a view function which returns the all verifiers details.
    function getAllVerifierDetails()
        external
        view
        returns (verifierDetails[] memory)
    {
        verifierDetails[] memory verifiersData = new verifierDetails[](
            _verifiersList.length
        );
        for (uint256 i = 0; i < _verifiersList.length; i++) {
            verifiersData[i] = getVerifierDetails(_verifiersList[i]);
        }
        return (verifiersData);
    }

    ///@dev getAllMerchantsContractAddress is a view function which returns the all merchants address.
    function getAllMerchantsContractAddress()
        external
        view
        returns (address[] memory)
    {
        return (_merchantsList);
    }

    ///@dev getMerchantDetails is a view function which returns the given merchant details.
    function getMerchantDetails(address merchantContractAddress_)
        public
        view
        returns (merchantDetails memory)
    {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        return (
            merchantDetails(
                merchant.getMerchantOwner(),
                merchant.getTheDotPayBankAddress(),
                merchant.getSharingCliffValue(),
                merchant.getMerchantUid(),
                merchant.getIsBlocked(),
                merchant.getTimeStamp(),
                merchant.getCurrentShare(),
                merchant.getCurrentBusinessName(),
                merchant.getCurrentBusinessCategory()
            )
        );
    }

    ///@dev getAllMerchantDetails is a view function which returns the all merchants details.
    function getAllMerchantDetails()
        external
        view
        returns (merchantDetails[] memory)
    {
        merchantDetails[] memory allMerchantDetails = new merchantDetails[](
            _merchantsList.length
        );
        for (uint256 i = 0; i < _merchantsList.length; i++) {
            allMerchantDetails[i] = getMerchantDetails(_merchantsList[i]);
        }
        return (allMerchantDetails);
    }

    ///@dev getCustomMerchantDetails is a view function which returns the given merchants details.
    function getCustomMerchantDetails(address[] memory merchants_)
        external
        view
        returns (merchantDetails[] memory)
    {
        merchantDetails[] memory customMerchnatDetails = new merchantDetails[](
            merchants_.length
        );
        for (uint256 i = 0; i < merchants_.length; i++) {
            customMerchnatDetails[i] = getMerchantDetails(merchants_[i]);
        }
        return (customMerchnatDetails);
    }

    ///@dev getMerchantAddress is a view function which returns the required merchant`s contract address.
    function getMerchantAddress(string memory merchantUid_)
        external
        view
        returns (address)
    {
        return (_merchantsContractAddressFromUid[merchantUid_]);
    }

    ///@dev getMerchantTransactions is a view function which returns the required merchant`s transactions.
    function getMerchantTransactions(address merchantContractAddress_)
        external
        view
        returns (transactionDetails[] memory)
    {
        return (_transactionsFromMerchants[merchantContractAddress_]);
    }

    ///@dev getMerchantBNBBalance is a view function which returns the required merchant`s BNB balance.
    function getMerchantBNBBalance(address merchantContractAddress_)
        external
        view
        returns (uint256)
    {
        return ((merchantContractAddress_).balance);
    }

    ///@dev getMerchantTokenBalance is a view function which returns the required merchant`s token balance.
    function getMerchantTokenBalance(
        address merchantContractAddress_,
        address tokenAddress_
    ) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress_);
        return (token.balanceOf(merchantContractAddress_));
    }

    ///@dev addMerchant is a  function which adds a new merchant.
    function addMerchant(
        address merchantOwnerAddress_,
        uint256 currentShare_,
        uint256 sharingCliffValue_,
        string memory uid_,
        string memory currentBusinessName_,
        string memory currentBusinessCategory_
    ) external returns (address) {
        if (_merchantsContractAddressFromUid[uid_] != address(0))
            revert MerchantAlreadyExists(
                _merchantsContractAddressFromUid[uid_],
                uid_,
                "Merchant for given uid already exists"
            );
        Merchant merchant = new Merchant(
            merchantOwnerAddress_,
            address(this),
            currentShare_,
            sharingCliffValue_,
            uid_,
            currentBusinessName_,
            currentBusinessCategory_
        );
        _merchantsList.push(address(merchant));
        _merchantsContractAddressFromUid[uid_] = address(merchant);
        _verifiersData[_msgSender()].addedMerchantsList.push(address(merchant));
        emit AddMerchant(address(merchant), _msgSender(), block.timestamp);
        return (address(merchant));
    }

    ///@dev blockMerchant is a  function which blocks a merchant.
    function blockMerchant(address merchantContractAddress_)
        external
        isVerifier
        returns (bool)
    {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        merchant.setIsBlocked(true);
        emit BlockMerchant(
            merchantContractAddress_,
            _msgSender(),
            block.timestamp
        );
        return (true);
    }

    ///@dev unBlockMerchant is a  function which unblocks a merchant.
    function unBlockMerchant(address merchantContractAddress_)
        external
        isVerifier
        returns (bool)
    {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        merchant.setIsBlocked(false);
        emit UnBlockMerchant(
            merchantContractAddress_,
            _msgSender(),
            block.timestamp
        );
        return (true);
    }

    ///@dev setCurrentShare is a  function which sets current share of a merchant.
    function setCurrentShare(
        address merchantContractAddress_,
        uint256 newShare_
    ) external isVerifier returns (bool) {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        if (newShare_ > merchant.getSharingCliffValue())
            revert UnExpectedSharePercentage(
                merchant.getSharingCliffValue(),
                newShare_,
                "newShare_ value can not be greater than SharingCliffValue"
            );
        merchant.setCurrentShare(newShare_);
        emit SetCurrentShareMerchant(
            merchantContractAddress_,
            newShare_,
            _msgSender(),
            block.timestamp
        );
        return (true);
    }

    ///@dev addVerifier is a  function which adds a new verifier.
    function addVerifier(
        address verifierAddress_,
        string memory name,
        string memory email,
        string memory contactNo_
    ) external isTheDotPayBankOwner returns (bool) {
        if (_verifiersData[verifierAddress_].timeStamp != 0)
            revert UnExpectedVerifiersAddress(
                verifierAddress_,
                "Error: Already Added as a verifier"
            );

        _verifiersList.push(verifierAddress_);

        address[] memory addedMerchants;

        _verifiersData[verifierAddress_] = verifierDetails(
            name,
            email,
            contactNo_,
            block.timestamp,
            false,
            addedMerchants
        );
        emit AddVerifier(verifierAddress_, _msgSender(), block.timestamp);
        return (true);
    }

    ///@dev blockVerifier is a  function which blocks a given verifier.
    function blockVerifier(address verifierAddress_)
        external
        isTheDotPayBankOwner
        returns (bool)
    {
        if (_verifiersData[verifierAddress_].timeStamp == 0)
            revert UnExpectedVerifiersAddress(
                verifierAddress_,
                "Error: NOT Added as a verifier"
            );

        _verifiersData[verifierAddress_].isBlocked = true;
        emit BlockVerifier(verifierAddress_, _msgSender(), block.timestamp);
        return (true);
    }

    ///@dev unblockVerifier is a  function which unBlocks a given verifier.
    function unblockVerifier(address verifierAddress_)
        external
        isTheDotPayBankOwner
        returns (bool)
    {
        if (_verifiersData[verifierAddress_].timeStamp == 0)
            revert UnExpectedVerifiersAddress(
                verifierAddress_,
                "Error: NOT Added as a verifier"
            );
        _verifiersData[verifierAddress_].isBlocked = false;
        emit BlockVerifier(verifierAddress_, _msgSender(), block.timestamp);
        return (true);
    }

    ///@dev withdrawBNB is a  function which withdraws BNB from contract.
    function withdrawBNB(uint256 amount_)
        external
        isTheDotPayBankOwner
        returns (bool)
    {
        if (address(this).balance < amount_)
            revert InSufficientBalanceError(
                address(this).balance,
                amount_,
                "available balance is less than required amount."
            );
        (payable(_theDotPayBankOwner)).transfer(amount_);
        emit WithdrawBNB(amount_, _msgSender(), block.timestamp);
        return (true);
    }

    ///@dev withdrawTokens is a  function which withdraws tokens from contract.
    function withdrawTokens(address tokenAddress_, uint256 amount_)
        external
        isTheDotPayBankOwner
        returns (bool)
    {
        IERC20 token = IERC20(tokenAddress_);
        if (token.balanceOf(address(this)) < amount_)
            revert InSufficientBalanceError(
                token.balanceOf(address(this)),
                amount_,
                "available balance is less than required amount."
            );

        token.transfer(_theDotPayBankOwner, amount_);
        emit WithdrawTokens(
            tokenAddress_,
            amount_,
            _msgSender(),
            block.timestamp
        );
        return (true);
    }

    ///@dev transferOwnerShip is a  function which transfer the ownership of contract.
    function transferOwnerShip(address newOwnerAddress_)
        external
        isTheDotPayBankOwner
        returns (bool)
    {
        if (newOwnerAddress_ == address(0))
            revert UnExpectedAddress(
                newOwnerAddress_,
                "Address of newOwnerAddress_ can not be address(0)."
            );
        emit TransferOwnerShip(
            _theDotPayBankOwner,
            newOwnerAddress_,
            block.timestamp
        );
        _theDotPayBankOwner = newOwnerAddress_;
        return (true);
    }

    ///@dev payWithToken is a  function which transact tokens.
    function payWithToken(
        address tokenAddress_,
        address merchantContractAddress_,
        uint256 tokenAmount_
    ) external returns (bool) {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        require(!merchant.getIsBlocked(), "Error: Merchant is blocked");
        IERC20 token = IERC20(tokenAddress_);
        if (token.balanceOf(_msgSender()) < tokenAmount_)
            revert InSufficientBalanceError(
                token.balanceOf(_msgSender()),
                tokenAmount_,
                "available balance is less than required amount."
            );
        if (token.allowance(_msgSender(), address(this)) < tokenAmount_)
            revert InSufficientAllowanceError(
                token.allowance(_msgSender(), address(this)),
                tokenAmount_,
                "available allowance is less than required amount."
            );

        uint256 theDotPaySharePercentage = merchant.getCurrentShare();
        uint256 theDotPayShare = ((tokenAmount_) * (theDotPaySharePercentage)) /
            (100e18);
        uint256 merchantShare = tokenAmount_ - theDotPayShare;

        token.transferFrom(
            _msgSender(),
            merchantContractAddress_,
            merchantShare
        );
        token.transferFrom(_msgSender(), address(this), theDotPayShare);
        _transactionsFromMerchants[merchantContractAddress_].push(
            transactionDetails(
                _msgSender(),
                merchantContractAddress_,
                tokenAmount_,
                block.timestamp,
                tokenAddress_
            )
        );
        emit PayWithToken(
            merchantContractAddress_,
            tokenAmount_,
            tokenAddress_,
            block.timestamp
        );
        return (true);
    }

    ///@dev payWithBNB is a  function which transact BNB.
    function payWithBNB(address merchantContractAddress_)
        external
        payable
        returns (bool)
    {
        IMerchant merchant = IMerchant(merchantContractAddress_);
        require(!merchant.getIsBlocked(), "Error: Merchant is blocked");

        uint256 theDotPaySharePercentage = merchant.getCurrentShare();
        uint256 theDotPayShare = ((msg.value) * (theDotPaySharePercentage)) /
            (100e18);
        uint256 merchantShare = msg.value - theDotPayShare;
        (payable(merchantContractAddress_)).transfer(merchantShare);
        (payable(address(this))).transfer(theDotPayShare);
        _transactionsFromMerchants[merchantContractAddress_].push(
            transactionDetails(
                _msgSender(),
                merchantContractAddress_,
                msg.value,
                block.timestamp,
                address(0)
            )
        );
        emit PayWithBNB(merchantContractAddress_, msg.value, block.timestamp);
        return (true);
    }

    receive() external payable {}

    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title TheDotPay`s Inerface
/// @author Ram Krishan Pandey
/// @notice Interface of TheDotPay
/// @dev Interface can be used to view features of TheDotPay
interface ITheDotPayBank {
    struct verifierDetails {
        string name;
        string email;
        string contactNo;
        uint256 timeStamp;
        bool isBlocked;
        address[] addedMerchantsList;
    }

    struct merchantDetails {
        address merchantBankAddress;
        address merchantOwner;
        uint256 merchantSharingCliffValue;
        string merchantUid;
        bool isMerchantBlocked;
        uint256 timeStamp;
        uint256 merchantCurrentShare;
        string merchantBusinessName;
        string merchantBusinessCategory;
    }

    struct transactionDetails {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        address tokenAddress;
    }

    ///@dev getTheDotPayBankDetails is a view function which returns the address of the dot pay contract and _theDotPayBankOwner.
    function getTheDotPayBankDetails()
        external
        view
        returns (address theDotPayBankAddress, address theDotPayBankOwner);

    ///@dev getBNBBalance is a view function which returns the BNB balance of the contract.
    function getBNBBalance() external view returns (uint256);

    ///@dev getTokenBalance is a view function which returns the given token balance of the contract.
    function getTokenBalance(address tokenAddress_)
        external
        view
        returns (uint256);

    ///@dev getVerifiersList is a view function which returns the verifiers list.
    function getVerifiersList() external view returns (address[] memory);

    ///@dev getVerifierDetails is a view function which returns the verifiers details.
    function getVerifierDetails(address verifierAddress_)
        external
        view
        returns (verifierDetails memory);

    ///@dev getAllVerifierDetails is a view function which returns the all verifiers details.
    function getAllVerifierDetails()
        external
        view
        returns (verifierDetails[] memory);

    ///@dev getAllMerchantsContractAddress is a view function which returns the all merchants address.
    function getAllMerchantsContractAddress()
        external
        view
        returns (address[] memory);

    ///@dev getMerchantDetails is a view function which returns the given merchant details.
    function getMerchantDetails(address merchantContractAddress_)
        external
        view
        returns (merchantDetails memory);

    ///@dev getAllMerchantDetails is a view function which returns the all merchants details.
    function getAllMerchantDetails()
        external
        view
        returns (merchantDetails[] memory);

    ///@dev getCustomMerchantDetails is a view function which returns the given merchants details.
    function getCustomMerchantDetails(address[] memory merchants_)
        external
        view
        returns (merchantDetails[] memory);

    ///@dev getMerchantAddress is a view function which returns the required merchant`s contract address.
    function getMerchantAddress(string memory merchantUid_)
        external
        view
        returns (address);

    ///@dev getMerchantTransactions is a view function which returns the required merchant`s transactions.
    function getMerchantTransactions(address merchantContractAddress_)
        external
        view
        returns (transactionDetails[] memory);

    ///@dev getMerchantBNBBalance is a view function which returns the required merchant`s BNB balance.
    function getMerchantBNBBalance(address merchantContractAddress_)
        external
        view
        returns (uint256);

    ///@dev getMerchantTokenBalance is a view function which returns the required merchant`s token balance.
    function getMerchantTokenBalance(
        address merchantContractAddress_,
        address tokenAddress_
    ) external view returns (uint256);

    ///@dev addMerchant is a  function which adds a new merchant.
    function addMerchant(
        address merchantOwnerAddress_,
        uint256 currentShare_,
        uint256 sharingCliffValue_,
        string memory uid_,
        string memory currentBusinessName_,
        string memory currentBusinessCategory_
    ) external returns (address);

    ///@dev blockMerchant is a  function which blocks a merchant.
    function blockMerchant(address merchantContractAddress_)
        external
        returns (bool);

    ///@dev unBlockMerchant is a  function which unblocks a merchant.
    function unBlockMerchant(address merchantContractAddress_)
        external
        returns (bool);

    ///@dev setCurrentShare is a  function which sets current share of a merchant.
    function setCurrentShare(
        address merchantContractAddress_,
        uint256 newShare_
    ) external returns (bool);

    ///@dev addVerifier is a  function which adds a new verifier.
    function addVerifier(
        address verifierAddress_,
        string memory name,
        string memory email,
        string memory contactNo
    ) external returns (bool);

    ///@dev blockVerifier is a  function which blocks a given verifier.
    function blockVerifier(address verifierAddress_) external returns (bool);

    ///@dev unblockVerifier is a  function which unBlocks a given verifier.
    function unblockVerifier(address verifierAddress_) external returns (bool);

    ///@dev withdrawBNB is a  function which withdraws BNB from contract.
    function withdrawBNB(uint256 amount_) external returns (bool);

    ///@dev withdrawTokens is a  function which withdraws tokens from contract.
    function withdrawTokens(address tokenAddress_, uint256 amount_)
        external
        returns (bool);

    ///@dev transferOwnerShip is a  function which transfer the ownership of contract.
    function transferOwnerShip(address newOwnerAddress_)
        external
        returns (bool);

    ///@dev payWithToken is a  function which transact tokens.
    function payWithToken(
        address tokenAddress_,
        address merchantContractAddress_,
        uint256 tokenAmount_
    ) external returns (bool);

    ///@dev payWithBNB is a  function which transact BNB.
    function payWithBNB(address merchantContractAddress_)
        external
        payable
        returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Merchant`s Inerface
/// @author Ram Krishan Pandey
/// @notice Interface of merchant
/// @dev Interface can be used to view features of merchant
interface IMerchant {
    ///@dev getTheDotPayBankAddress is a view function which returns the address of the dot pay contract.
    function getTheDotPayBankAddress() external view returns (address);

    ///@dev getSharingCliffValue is a view function which returns the _SHARING_CLIFF_VALUE.
    function getSharingCliffValue() external view returns (uint256);

    ///@dev getMerchantUid is a view function which returns the merchant uid.
    function getMerchantUid() external view returns (string memory);

    ///@dev getIsBlocked is a view function which returns the blocked state of merchant.
    function getIsBlocked() external view returns (bool);

    ///@dev getCurrentShare is a view function which returns the current share of the dot pay bank.
    function getCurrentShare() external view returns (uint256);

    ///@dev getMerchantOwner is a view function which returns the owner address of merchant contract.
    function getMerchantOwner() external view returns (address);

    ///@dev getCurrentBusinessName is a view function which returns the Current Business Name of merchant.
    function getCurrentBusinessName() external view returns (string memory);

    ///@dev getCurrentBusinessCategory is a view function which returns the Current Business Category.
    function getCurrentBusinessCategory() external view returns (string memory);

    ///@dev getMerchantAddress is a view function which returns the Merchant Contract Address.
    function getMerchantAddress() external view returns (address);

    ///@dev getTimeStamp is a view function which returns the timeStamp.
    function getTimeStamp() external view returns (uint256);

    ///@dev getBNBBalance is a view function which returns the BNB balance of merchant contract.
    function getBNBBalance() external view returns (uint256);

    ///@dev getTokenBalance is a view function which returns the token balance of the given token address of merchant contract.
    function getTokenBalance(address tokenAddress_)
        external
        view
        returns (uint256);

    ///@dev setIsBlocked is a  function which changes the blocked state of merchant emiting SetIsBlocked event.
    function setIsBlocked(bool newStatus_) external returns (bool);

    ///@dev setCurrentShare is a function which changes the current share of merchant emiting SetCurrentShare event.
    function setCurrentShare(uint256 newShare_) external returns (bool);

    ///@dev transferMerchantOwnership is a function which changes the current owner of merchant emiting SetMerchantOwner event.
    function transferMerchantOwnership(address newOwner_)
        external
        returns (bool);

    ///@dev setCurrentBusinessName is a function which changes the current business name emiting SetCurrentBusinessName event.
    function setCurrentBusinessName(string memory newBusinessName_)
        external
        returns (bool);

    ///@dev setCurrentBusinessCategory is a function which changes the Current Business Category emiting SetCurrentBusinessCategory event.
    function setCurrentBusinessCategory(string memory newBusinessCategory_)
        external
        returns (bool);

    ///@dev transferToken is a function which transfers the tokens of merchant contract to to_ address.
    function transferToken(
        address tokenAddress_,
        uint256 tokenAmount_,
        address to_
    ) external returns (bool);

    ///@dev withdrawBNB is a function which withdraw the BNB to the to_ address.
    function withdrawBNB(uint256 amount_, address to_) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./interfaces/IMerchant.sol";

/// @title Merchant Contract
/// @author Ram Krishan Pandey
/// @dev This Contract is governed by TheDotPay bank
contract Merchant is IMerchant, Context {
    //State-Variables

    ///@dev _THE_DOT_PAY_BANK is address type private state variable which stores the value of the dotpay bank contract address.
    ///@notice _THE_DOT_PAY_BANK is an immutable variable(i.e. value can not be re-initilized) and initilized at the time of constructor function call.
    address private immutable _THE_DOT_PAY_BANK;

    ///@dev _SHARING_CLIFF_VALUE is uint256 type private state variable which stores the maximum possible share value of the dotpay bank per transaction.
    ///@notice _SHARING_CLIFF_VALUE is an immutable variable(i.e. value can not be re-initilized) and initilized at the time of constructor function call.
    uint256 private immutable _SHARING_CLIFF_VALUE;

    ///@dev _uid is string type private state variable which stores the unique identity of merchant generated by firebase.
    ///@notice _uid is a immutable variable(i.e. value can not be re-initilized) and initilized at the time of constructor function call but it is not marked immutable because string variables can`t be declared immutable in solidity.
    string private _uid;

    ///@dev _isBlocked is boolean type private state variable which stores the current blocked state of the merchant.
    ///@notice _isBlocked can only be modified through the dotpay bank contract.
    bool private _isBlocked;

    ///@dev _currentShare is uint256 type private state variable which stores the current share value of the dotpay bank per transaction.
    ///@notice _currentShare can only be modified through the dotpay bank contract.
    uint256 private _currentShare;

    ///@dev _merchantOwner is address type private state variable which stores the wallet address of this merchant contract.
    ///@notice _merchantOwner can only be modified through the _merchantOwner wallet.
    address private _merchantOwner;

    ///@dev _currentBusinessName is string type private state variable which stores the business name of merchant.
    ///@notice _currentBusinessName can only be modified through the _merchantOwner wallet.
    string private _currentBusinessName;

    ///@dev _currentBusinessCategory is string type private state variable which stores the business category of merchant.
    ///@notice _currentBusinessCategory can only be modified through the dotpay bank contract.
    string private _currentBusinessCategory;

    ///@dev _timeStamp is uint256 type private state variable which stores timestamp of merchant.
    ///@notice _timeStamp can not be modified.
    uint256 private immutable _timeStamp;

    //Errors

    ///@dev UnauthorisedAccess is an Error which occures when an Unauthorised wallet address signs the transaction.
    ///@notice UnauthorisedAccess emits requireCallerAddress_ ,  requesterCallerAddress_ and reason_.
    error UnauthorisedAccess(
        address requireCallerAddress_,
        address requesterCallerAddress_,
        string reason_
    );

    ///@dev InSufficientBalanceError is an Error which occures when contract balance is insufficient.
    ///@notice InSufficientBalanceError emits availableBalance_ ,  requestedAmount_ and reason_.
    error InSufficientBalanceError(
        uint256 availableBalance_,
        uint256 requestedAmount_,
        string reason_
    );

    ///@dev UnExpectedSharePercentage is an Error which occures when an given share percentage is more than _SHARING_CLIFF_VALUE.
    ///@notice UnExpectedSharePercentage emits sharingCliffValue_ ,  requestedSharingValue_.
    error UnExpectedSharePercentage(
        uint256 sharingCliffValue_,
        uint256 requestedSharingValue_,
        string reason_
    );

    ///@dev UnExpectedShare is an Error which occures when an given share percentage is 0.
    ///@notice UnExpectedShare emits requestedSharingValue_ and reason_.
    error UnExpectedShare(uint256 requestedSharingValue_, string reason_);

    ///@dev UnExpectedAddress is an Error which occures when an given address is address(0).
    ///@notice UnExpectedAddress emits requestedAddressValue_ and reason_.
    error UnExpectedAddress(address requestedAddressValue_, string reason_);

    //Events

    ///@dev SetIsBlocked occurs emiting oldStatus_ and newStatus_ of merchant when the blocked state of merchant is changes.
    event SetIsBlocked(bool indexed oldStatus_, bool indexed newStatus_);

    ///@dev SetCurrentShare occurs emiting oldShare_ and newShare_  when the current share of the dot pay bank changes.
    event SetCurrentShare(uint256 indexed oldShare_, uint256 indexed newShare_);

    ///@dev SetMerchantOwner occurs emiting oldOwner_ and newOwner_  when the owner of merchant contract changes.
    event TransferMerchantOwnership(
        address indexed oldOwner_,
        address indexed newOwner_
    );

    ///@dev SetCurrentBusinessName occurs emiting oldBusinessName_ and newBusinessName_  when the business name of merchant changes.
    event SetCurrentBusinessName(
        string indexed oldBusinessName_,
        string indexed newBusinessName_
    );

    ///@dev SetCurrentBusinessCategory occurs emiting oldBusinessCategory_ and newBusinessCategory_ when the business category of merchant changes.
    event SetCurrentBusinessCategory(
        string indexed oldBusinessCategory_,
        string indexed newBusinessCategory_
    );

    ///@dev TransferToken occurs emiting tokenAddress_, tokenAmount_ and receiverAddress_ when the tokens from the merchant contract is transfered.
    event TransferToken(
        address indexed tokenAddress_,
        uint256 indexed tokenAmount_,
        address indexed receiverAddress_
    );

    ///@dev WithdrawBNB occurs emiting amount_, timeStamp_ and receiverAddress_ when the BNB from the merchant contract is transfered.
    event WithdrawBNB(
        uint256 indexed amount_,
        address indexed receiverAddress_,
        uint256 indexed timeStamp_
    );

    //Modifiers

    ///@dev isMerchantOwner modifier checks that transaction signer is merchant owner else returns UnauthorisedAccess Error.
    modifier isMerchantOwner() {
        if (_msgSender() != _merchantOwner)
            revert UnauthorisedAccess(
                _merchantOwner,
                _msgSender(),
                "Only _merchantOwner can call this function."
            );
        _;
    }

    ///@dev isTheDotPayBank modifier checks that transaction signer is _THE_DOT_PAY_BANK else returns UnauthorisedAccess Error.
    modifier isTheDotPayBank() {
        if (_msgSender() != _THE_DOT_PAY_BANK)
            revert UnauthorisedAccess(
                _THE_DOT_PAY_BANK,
                _msgSender(),
                "Only _THE_DOT_PAY_BANK can call this function."
            );
        _;
    }

    ///@dev initialize state variables with constructor parameter and merchant blocked state to false.
    constructor(
        address merchantOwner_,
        address theDotPayBank_,
        uint256 currentShare_,
        uint256 sharingCliffValue_,
        string memory uid_,
        string memory currentBusinessName_,
        string memory currentBusinessCategory_
    ) {
        if (merchantOwner_ == address(0))
            revert UnExpectedAddress(
                _merchantOwner,
                "Address of _merchantOwner can not be address(0)."
            );

        if (theDotPayBank_ == address(0))
            revert UnExpectedAddress(
                theDotPayBank_,
                "Address of _THE_DOT_PAY_BANK can not be address(0)."
            );

        if (currentShare_ == 0)
            revert UnExpectedShare(
                currentShare_,
                "currentShare_ can not be equal to 0."
            );

        if (sharingCliffValue_ == 0)
            revert UnExpectedShare(
                sharingCliffValue_,
                "sharingCliffValue_ can not be equal to 0."
            );

        _THE_DOT_PAY_BANK = theDotPayBank_;
        _SHARING_CLIFF_VALUE = sharingCliffValue_;
        _uid = uid_;
        _isBlocked = false;
        _currentShare = currentShare_;
        _merchantOwner = merchantOwner_;
        _currentBusinessName = currentBusinessName_;
        _currentBusinessCategory = currentBusinessCategory_;
        _timeStamp = block.timestamp;
    }

    ///@dev getTheDotPayBankAddress is a view function which returns the address of the dot pay contract.
    function getTheDotPayBankAddress()
        external
        view
        override
        returns (address)
    {
        return (_THE_DOT_PAY_BANK);
    }

    ///@dev getSharingCliffValue is a view function which returns the _SHARING_CLIFF_VALUE.
    function getSharingCliffValue() external view override returns (uint256) {
        return (_SHARING_CLIFF_VALUE);
    }

    ///@dev getMerchantUid is a view function which returns the merchant uid.
    function getMerchantUid() external view override returns (string memory) {
        return (_uid);
    }

    ///@dev getIsBlocked is a view function which returns the blocked state of merchant.
    function getIsBlocked() external view override returns (bool) {
        return (_isBlocked);
    }

    ///@dev getCurrentShare is a view function which returns the current share of the dot pay bank.
    function getCurrentShare() external view override returns (uint256) {
        return (_currentShare);
    }

    ///@dev getMerchantOwner is a view function which returns the owner address of merchant contract.
    function getMerchantOwner() external view override returns (address) {
        return (_merchantOwner);
    }

    ///@dev getCurrentBusinessName is a view function which returns the Current Business Name of merchant.
    function getCurrentBusinessName()
        external
        view
        override
        returns (string memory)
    {
        return (_currentBusinessName);
    }

    ///@dev getCurrentBusinessCategory is a view function which returns the Current Business Category.
    function getCurrentBusinessCategory()
        external
        view
        override
        returns (string memory)
    {
        return (_currentBusinessCategory);
    }

    ///@dev getTimeStamp is a view function which returns the timeStamp.
    function getTimeStamp() external view override returns (uint256) {
        return (_timeStamp);
    }

    ///@dev getMerchantAddress is a view function which returns the Merchant Contract Address.
    function getMerchantAddress() external view override returns (address) {
        return (address(this));
    }

    ///@dev getBNBBalance is a view function which returns the BNB balance of merchant contract.
    function getBNBBalance() external view override returns (uint256) {
        return (address(this).balance);
    }

    ///@dev getTokenBalance is a view function which returns the token balance of the given token address of merchant contract.
    function getTokenBalance(address tokenAddress_)
        external
        view
        override
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress_);
        uint256 balance = token.balanceOf(address(this));
        return (balance);
    }

    ///@dev setIsBlocked is a  function which changes the blocked state of merchant emiting SetIsBlocked event.
    function setIsBlocked(bool newStatus_)
        external
        override
        isTheDotPayBank
        returns (bool)
    {
        emit SetIsBlocked(_isBlocked, newStatus_);
        _isBlocked = newStatus_;
        return (true);
    }

    ///@dev setCurrentShare is a function which changes the current share of merchant emiting SetCurrentShare event.
    function setCurrentShare(uint256 newShare_)
        external
        override
        isTheDotPayBank
        returns (bool)
    {
        if (newShare_ == 0)
            revert UnExpectedShare(newShare_, "newShare_ value can not be 0.");

        if (newShare_ > _SHARING_CLIFF_VALUE)
            revert UnExpectedSharePercentage(
                _SHARING_CLIFF_VALUE,
                newShare_,
                "newShare_ value can not be greater than _SHARING_CLIFF_VALUE."
            );

        emit SetCurrentShare(_currentShare, newShare_);
        _currentShare = newShare_;
        return (true);
    }

    ///@dev transferMerchantOwnership is a function which changes the current owner of merchant emiting SetMerchantOwner event.
    function transferMerchantOwnership(address newOwner_)
        external
        override
        isMerchantOwner
        returns (bool)
    {
        if (newOwner_ == address(0))
            revert UnExpectedAddress(
                newOwner_,
                "Address of newOwner_ can not be address(0)."
            );

        emit TransferMerchantOwnership(_merchantOwner, newOwner_);
        _merchantOwner = newOwner_;
        return (true);
    }

    ///@dev setCurrentBusinessName is a function which changes the current business name emiting SetCurrentBusinessName event.
    function setCurrentBusinessName(string memory newBusinessName_)
        external
        override
        isMerchantOwner
        returns (bool)
    {
        emit SetCurrentBusinessName(_currentBusinessName, newBusinessName_);
        _currentBusinessName = newBusinessName_;
        return (true);
    }

    ///@dev setCurrentBusinessCategory is a function which changes the Current Business Category emiting SetCurrentBusinessCategory event.
    function setCurrentBusinessCategory(string memory newBusinessCategory_)
        external
        override
        isTheDotPayBank
        returns (bool)
    {
        emit SetCurrentBusinessCategory(
            _currentBusinessCategory,
            newBusinessCategory_
        );
        _currentBusinessCategory = newBusinessCategory_;
        return (true);
    }

    ///@dev transferToken is a function which transfers the tokens of merchant contract to to_ address.
    function transferToken(
        address tokenAddress_,
        uint256 tokenAmount_,
        address to_
    ) external override isMerchantOwner returns (bool) {
        IERC20 token = IERC20(tokenAddress_);
        uint256 balance = token.balanceOf(address(this));
        if (balance < tokenAmount_)
            revert InSufficientBalanceError(
                balance,
                tokenAmount_,
                "Contract does not have required amount of tokens."
            );

        token.transfer(to_, tokenAmount_);
        emit TransferToken(tokenAddress_, tokenAmount_, to_);
        return (true);
    }

    ///@dev withdrawBNB is a function which withdraw the BNB to the to_ address.
    function withdrawBNB(uint256 amount_, address to_)
        external
        override
        isMerchantOwner
        returns (bool)
    {
        if (address(this).balance < amount_)
            revert InSufficientBalanceError(
                address(this).balance,
                amount_,
                "Contract does not have required amount of BNB."
            );
        payable(to_).transfer(amount_);
        emit WithdrawBNB(amount_, to_, block.timestamp);
        return (true);
    }

    receive() external payable {}

    fallback() external payable {}
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