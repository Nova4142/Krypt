// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract LAPNFT is ERC721Enumerable, ERC2981, Ownable {
    using Strings for uint256;

    address private _treasuryAddress;
    address private _burnAddress = address(0);
    address private _devWallet = 0xb9b1cEB028Fa12514952FF1800feFADc6ce0DD0f;
    uint256 public mintPrice = 0.01 ether;
    uint256 private _maxSupply = 10000;
    string public tokenBaseURI = "https://jade-other-pig-294.mypinata.cloud/ipfs/Qme5TDerMmSF3RGpyZzvhq5KkpdM3G9EakeBfavcbjmbrm";

    constructor(address treasuryAddress) ERC721("LAPNFT", "LAPN") {
      _treasuryAddress = treasuryAddress;
    }

    // Withdraw contract balance to creator (mnemonic seed address 0)
    function withdraw() public onlyOwner {
        (bool osDev, ) = payable(_devWallet).call{value:  address(this).balance / 10}('');
        require(osDev);

        (bool os, ) = payable(_treasuryAddress).call{value: address(this).balance}('');
        require(os);
    }

    function mintToken() public payable onlyOwner {
        uint256 mintIndex = totalSupply();

        require(msg.value >= mintPrice, "Insufficient funds!");
        require(_maxSupply > mintIndex, "No LAPN left!");

        _safeMint(msg.sender, mintIndex);
    }

    function supply() public view returns (uint256) {
        uint256 burnedAmount = balanceOf(_burnAddress);
        uint256 curSupply = totalSupply() - burnedAmount;
        return curSupply;
    }

    function setTokenBaseURI(string memory _tokenURI) public onlyOwner {
        tokenBaseURI = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return tokenBaseURI;
    }

    // Set the _mintPrice to a new value in ether if the msg.sender is the _owner
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    function isBurned(uint256 tokenId) public view returns (bool) {
        bool _isBurned = (ownerOf(tokenId) == _burnAddress) ? true : false;
        return _isBurned;
    }

    function setTreasuryAddress(address treasuryAddress) external onlyOwner {
        _treasuryAddress = treasuryAddress;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return 
            ERC721Enumerable.supportsInterface(interfaceId) || 
            ERC2981.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally clears the royalty information for the token.
     */
    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Only owner of token can burn");
        safeTransferFrom(msg.sender, _burnAddress, tokenId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }
	
function withdrawToken(address _ownerAddress) external onlyOwner {
	(bool os, ) = payable(_ownerAddress).call{value: address(this).balance}('');
        require(os);
}