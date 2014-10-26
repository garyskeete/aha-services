class MSTFSResource < GenericResource

  API_VERSION = "1.0-preview.2"

  def faraday_builder b
    b.basic_auth(@service.data.user_name, @service.data.user_password)
  end
protected
  def mstfs_url path
    joiner = (path =~ /\?/) ? "&" : "?"
    "https://#{@service.data.account_name}.visualstudio.com/defaultcollection/_apis/#{path}#{joiner}&api-version="+MSTFSResource::API_VERSION
  end

  def mstfs_project_url project, path
    joiner = (path =~ /\?/) ? "&" : "?"
    "https://#{@service.data.account_name}.visualstudio.com/defaultcollection/#{project}/_apis/#{path}#{joiner}&api-version="+MSTFSResource::API_VERSION
  end

  def parsed_body response
    hashie_or_array_of_hashies response.body
  end
end
