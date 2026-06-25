public class InvoiceGenerationController {
  public class GenerateInvoiceException extends Exception {
  }

  @AuraEnabled
  public static void getPDF(Id oppId) {
    try {
      Blob pdfBinary = getBinaryPdf(oppId);
      String fileName = getFileName(oppId);

      List<ContentDocumentLink> existingDoc = getExistingDocument(
        oppId,
        fileName
      );
      ContentVersion cv = createCVWithoutInsert(pdfBinary, fileName);

      if (!existingDoc.isEmpty()) {
        cv.ContentDocumentId = existingDoc[0].ContentDocumentId;
      }

      insert cv;

      if (existingDoc.isEmpty()) {
        createContentDocumentLink(oppId, cv.Id);
      }
    } catch (Exception failGenerateEx) {
      throw new GenerateInvoiceException(
        'fail to generate invoice ' + failGenerateEx.getMessage()
      );
    }
  }

  private static Blob getBinaryPdf(Id oppId) {
    PageReference pdfPage = Page.InvoicePDF;
    pdfPage.getParameters().put('id', oppId);

    Blob pdf;
    if (Test.isRunningTest()) {
      pdf = Blob.valueOf('Test');
    } else {
      pdf = pdfPage.getContentAsPDF();
    }

    return pdf;
  }

  private static String getFileName(Id oppId) {
    Opportunity o = [
      SELECT Invoice_Number__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
    return o.Invoice_Number__c;
  }

  private static List<ContentDocumentLink> getExistingDocument(
    Id oppId,
    String fileName
  ) {
    List<ContentDocumentLink> linkDocuments = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :oppId AND ContentDocument.Title = :fileName
      LIMIT 1
    ];
    return linkDocuments;
  }

  private static ContentVersion createCVWithoutInsert(
    Blob pdf,
    String fileName
  ) {
    ContentVersion cv = new ContentVersion();
    cv.Title = fileName;
    cv.PathOnClient = fileName + '.pdf';
    cv.VersionData = pdf;
    return cv;
  }

  private static void createContentDocumentLink(Id oppId, Id cvId) {
    Id conDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvId
    ]
    .ContentDocumentId;
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = conDocId;
    cdl.LinkedEntityId = oppId;
    cdl.ShareType = 'V';
    insert cdl;
  }
}