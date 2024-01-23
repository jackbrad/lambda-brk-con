import json
from langchain.document_loaders import AmazonTextractPDFLoader
from langchain.llms import Bedrock
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
           
     
def handler(event, context): 
    
    bucket = event["Document"]['S3Object']['Bucket']
    name = event["Document"]['S3Object']['Name']
    file_path = "s3://{bucket}/{name}".format(bucket = bucket, name = name )

    loader = AmazonTextractPDFLoader(file_path)
    document = loader.load()
    
    template = """
    
    Given a full document, give me a summary. Do not explain the answer. Just give the answer.
    
    <document>{doc_text}</document>
    <summary>"""
    
    prompt = PromptTemplate(template=template, input_variables=["doc_text"])
    
    llm = Bedrock(model_id="anthropic.claude-v2", region_name='us-east-1')
    num_tokens = llm.get_num_tokens(document[0].page_content)
    
    llm_chain = LLMChain(prompt=prompt, llm=llm)
    summ = llm_chain.run(document[0].page_content)
    
    #return object
    ret={}
    summary={}
    summary = summ.replace("</summary>","").strip()
    ret['summary'] = summary
    
    print(ret)

    return {
        'statusCode': 200, 
        'body': ret
    }








